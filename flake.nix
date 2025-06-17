{
  description = "jreslock dotfiles with home-manager devenv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Remove nix-darwin from the arguments
  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      system = builtins.currentSystem or "x86_64-linux";
      username = "jreslock";
    in {
      homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };
        modules = [
          ./home.nix
          {
            home = {
              inherit username;
              homeDirectory = if builtins.match ".*-linux" system != null
                              then "/home/${username}"
                              else "/Users/${username}";
              stateVersion = "24.05";
            };
          }
        ];
      };
    };
}
