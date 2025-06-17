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
  outputs = inputs@{ self, nixpkgs, home-manager, ... }@inputs:
    let
      username = "jreslock";
    in {
      homeConfigurations = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ] (system:
        home-manager.lib.homeManagerConfiguration {
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
        } 
      );
    };
}
