{
  description = "jreslock dotfiles with home-manager devenv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Remove nix-darwin from the arguments
  outputs = inputs@{ self, nixpkgs, home-manager, devenv, ... }:
    let
      lib = nixpkgs.lib;
      username = "jreslock";

      # SIMPLIFY THIS FUNCTION
      mkPkgsForSystem = system: import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          # Use the default devenv overlay for all systems
          overlays = [ devenv.overlays.default ];
        };

      commonHomeManagerModules = [
        ./home.nix
      ];

      supportedSystems = [
        "x86_64-darwin"
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

    in {
      homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgsForSystem builtins.currentSystem;
        modules = commonHomeManagerModules ++ [
          {
            home = {
              inherit username;
              homeDirectory = if builtins.match ".*-linux" builtins.currentSystem != null
                              then "/home/${username}"
                              else "/Users/${username}";
              stateVersion = "24.11";
            };
          }
        ];
      };

      # This section is now correct
      devShells = builtins.listToAttrs (builtins.map (system:
        {
          name = system;
          value = {
            default = devenv.lib.mkShell {
              inputs = inputs // { inherit self; };
              pkgs = mkPkgsForSystem system;
              modules = [
                { devenv.root = builtins.getEnv "DEVENV_PROJECT_ROOT"; }
                ./dev-tools.nix
              ];
            };
          };
        }
      ) supportedSystems);
    };
}
