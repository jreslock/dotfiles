{
  description = "jreslock dotfiles with home-manager";

  inputs = {
    nixpkgs.url  = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: let
    systems = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" ];
  in {
    homeConfigurations = builtins.listToAttrs (map (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        name  = system;
        value = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            {
              home.username            = "jreslock";
              home.homeDirectory       = "/Users/jreslock";
              home.backupFileExtension = "backup";
            }
            ./home.nix
          ];
        };
      }) systems);
  };
}
