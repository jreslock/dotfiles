{
  description = "jreslock dotfiles with home-manager devenv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    homeConfigurations = nixpkgs.lib.genAttrs [
      "jreslock@aarch64-darwin"
      "jreslock@x86_64-darwin"
      "jreslock@x86_64-linux"
      "jreslock@aarch64-linux"
    ] (name:
      let
        parts = builtins.match "([^@]+)@(.+)" name;
        username = builtins.elemAt parts 0;
        system = builtins.elemAt parts 1;
        homeDirectory = if builtins.match ".*-linux" system != null
                        then "/home/${username}"
                        else "/Users/${username}";
      in
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = [
            ./home.nix
            {
              home = {
                inherit username homeDirectory;
                stateVersion = "24.05";
              };
            }
          ];
        }
    );
  };
}
