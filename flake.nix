{
  description = "jreslock dotfiles with home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # Current stable branch
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05"; # Match nixpkgs branch
      inputs.nixpkgs.follows = "nixpkgs"; # Ensure HM uses the same Nixpkgs
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: # @ inputs is optional, but doesn't hurt
    let
      username = "jreslock";

      # Define a common Home Manager module that contains most of your config
      commonHomeManagerModules = [
        ./home.nix
        # Add any other common modules here, e.g., ./modules/git.nix, ./modules/zsh.nix
      ];

      # A list of all systems you intend to support.
      supportedSystems = [
        "x86_64-darwin"
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Helper to create an instance of Nixpkgs for a given system
      # This is crucial for *building* packages for a target system.
      mkPkgsForSystem = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

    in {
      # This is the PRIMARY homeConfiguration for your user.
      # It leverages `builtins.currentSystem` directly at the top-level output.
      # This is what `home-manager switch --flake .#jreslock` expects.
      homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgsForSystem builtins.currentSystem; # pkgs for the CURRENT system
        modules = commonHomeManagerModules ++ [
          {
            home = {
              inherit username;
              homeDirectory = if builtins.match ".*-linux" builtins.currentSystem != null
                              then "/home/${username}"
                              else "/Users/${username}";
              stateVersion = "24.05";
            };
          }
        ];
      };

      # OPTIONAL: You can still define explicit configurations for specific systems
      # if you ever need to specifically build for or target them (e.g. cross-build)
      # or if you have system-specific overrides that cannot be handled by the single common config.
      # These would be accessed via `home-manager switch --flake .#jreslock-aarch64-darwin`
      # homeConfigurations."${username}-aarch64-darwin" = home-manager.lib.homeManagerConfiguration {
      #   pkgs = mkPkgsForSystem "aarch64-darwin";
      #   modules = commonHomeManagerModules ++ [
      #     {
      #       home = {
      #         inherit username;
      #         homeDirectory = "/Users/${username}"; # Explicit for macOS
      #         stateVersion = "24.05";
      #       };
      #     }
      #     # Any aarch64-darwin specific modules here
      #   ];
      # };
      # homeConfigurations."${username}-x86_64-linux" = home-manager.lib.homeManagerConfiguration {
      #   pkgs = mkPkgsForSystem "x86_64-linux";
      #   modules = commonHomeManagerModules ++ [
      #     {
      #       home = {
      #         inherit username;
      #         homeDirectory = "/home/${username}"; # Explicit for Linux
      #         stateVersion = "24.05";
      #       };
      #     }
      #     # Any x86_64-linux specific modules here
      #   ];
      # };

      # Development shells for *your* dotfiles repository
      # This is for developing your Nix configs, not your general project work.
      # It leverages `builtins.currentSystem` implicitly for convenience.
      devShells.${builtins.currentSystem}.default = mkPkgsForSystem builtins.currentSystem.mkShell {
        packages = [
          (mkPkgsForSystem builtins.currentSystem).nixpkgs-fmt # Nix formatter
          (mkPkgsForSystem builtins.currentSystem).git         # git is often useful in devShells
          # Add other tools needed for developing this flake itself (e.g., specific Nix tools)
        ];
        # shellHook = ''
        #   echo "Entering dotfiles dev shell for ${builtins.currentSystem}"
        # '';
      };
    };
}
