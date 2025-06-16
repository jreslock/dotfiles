{
  description = "jreslock dotfiles with home-manager";

  inputs = {
    nixpkgs.url  = "github:NixOS/nixpkgs/nixos-24.05"; # Changed to 24.05 stable branch
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05"; # Match nixpkgs stable branch
      inputs.nixpkgs.follows = "nixpkgs"; # Ensure HM uses the same Nixpkgs
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # Define your username - this remains constant across your machines
      username = "jreslock";

      # Define a common Home Manager module that contains most of your config
      # This is the path to your main home.nix
      commonHomeManagerModules = [
        ./home.nix
        # Add any other common modules here, e.g., ./modules/git.nix, ./modules/zsh.nix
      ];

      # A helper function to create a homeManagerConfiguration for a given system
      mkHomeConfig = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = commonHomeManagerModules ++ [
            {
              # Inherit the username from the outer scope
              home.inherit username;
              # Dynamically set homeDirectory based on system for Linux/macOS
              # On Linux, typically /home/<username>
              # On macOS, typically /Users/<username>
              home.homeDirectory = if builtins.match ".*-linux" system != null
                                  then "/home/${username}"
                                  else "/Users/${username}";

              # Crucial: Set stateVersion matching your Nixpkgs release
              # This example uses 24.05, adjust if you use a different stable version
              home.stateVersion = "24.05";
            }
          ];
        };

    in {
      # Define specific homeConfigurations for each supported system
      # This allows you to explicitly target a config like `.jreslock-aarch64-darwin`
      # or `.jreslock-x86_64-linux` if you have system-specific overrides.
      # For a single common config for all, you only strictly need one.

      # macOS (Apple Silicon)
      homeConfigurations."${username}-aarch64-darwin" = mkHomeConfig "aarch64-darwin";
      # macOS (Intel)
      homeConfigurations."${username}-x86_64-darwin" = mkHomeConfig "x86_64-darwin";
      # Linux (ARM64)
      homeConfigurations."${username}-aarch64-linux" = mkHomeConfig "aarch64-linux";
      # Linux (AMD64)
      homeConfigurations."${username}-x86_64-linux" = mkHomeConfig "x86_64-linux";


      # OPTIONAL BUT RECOMMENDED: Provide a 'default' configuration that
      # automatically detects the current system. This is the most convenient for day-to-day use.
      # When you run `home-manager switch --flake .#jreslock`, Nix will implicitly
      # determine the current system and use that.
      homeConfigurations."${username}" = mkHomeConfig builtins.currentSystem;

      # You can also add devShells for developing the flake itself
      devShells.aarch64-darwin.default = pkgs.mkShell {
        packages = [ pkgs.nixpkgs-fmt ];
      };
      # Add other devShells for other systems if you intend to develop the flake on them
      # devShells.x86_64-linux.default = pkgs.mkShell { packages = [ pkgs.nixpkgs-fmt ]; };
    };
}
