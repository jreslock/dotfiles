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
      commonHomeManagerModules = [
        ./home.nix
        # Add any other common modules here, e.g., ./modules/git.nix, ./modules/zsh.nix
      ];

      # --- Define a system-specific pkgs for the current system ---
      # This 'pkgs' will be used for devShells and the default homeConfiguration
      # It's imported once at the top level of the 'outputs' let-block.
      pkgs = import nixpkgs {
        system = builtins.currentSystem; # Import pkgs for the system where the flake is being evaluated
        config = {
          allowUnfree = true;
        };
      };

      # A helper function to create a homeManagerConfiguration for a given system
      mkHomeConfig = system:
        let
          # IMPORTANT: This 'pkgs' is specific to the *target system* of the Home Manager config.
          # It's crucial for cross-compilation if you were building for other systems.
          # It's distinct from the top-level 'pkgs' which is for the *current system*.
          hmPkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = hmPkgs; # Use hmPkgs here for the Home Manager configuration
          modules = commonHomeManagerModules ++ [
            {
              home = {
                username = username;
                homeDirectory = if builtins.match ".*-linux" system != null
                                then "/home/${username}"
                                else "/Users/${username}";

                stateVersion = "24.05";
              };
            }
          ];
        };

    in {
      # Define specific homeConfigurations for each supported system
      homeConfigurations."${username}-aarch64-darwin" = mkHomeConfig "aarch64-darwin";
      homeConfigurations."${username}-x86_64-darwin" = mkHomeConfig "x86_64-darwin";
      homeConfigurations."${username}-aarch64-linux" = mkHomeConfig "aarch64-linux";
      homeConfigurations."${username}-x86_64-linux" = mkHomeConfig "x86_64-linux";

      # OPTIONAL BUT RECOMMENDED: Provide a 'default' configuration that
      # automatically detects the current system.
      homeConfigurations."${username}" = mkHomeConfig builtins.currentSystem;

      # You can also add devShells here if you need them for building/developing your dotfiles flake itself
      # Now, 'pkgs' from the top-level let-block is in scope here.
      devShells.${builtins.currentSystem}.default = pkgs.mkShell {
        packages = [ pkgs.nixpkgs-fmt ]; # Example: a formatter for your Nix files
      };
      # If you need devShells for other specific systems (e.g., cross-compilation devShells)
      # devShells.aarch64-darwin.specific = mkShell "aarch64-darwin" { packages = [ pkgs.my-arm-tool ]; };
    };
}
