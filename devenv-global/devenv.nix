# ~/devenv-global/devenv.nix
{ pkgs, ... }:

{
  # --- Languages you work with ---
  languages = {
    # Python
    python = {
      enable = true;
      # You can specify a default version, or let Nix choose,
      # and use tools like 'rye' or 'pipenv' for project-specific versions.
      # version = pkgs.python311;
      # Add common global Python packages you always want
      packages = with pkgs.python3Packages; [
        poetry
        pipx # For installing other Python CLIs in isolated environments
      ];
    };
    # Go
    go = {
      enable = true;
      # version = pkgs.go_1_22; # Specify a version if you prefer
    };
  };

  # --- Core development tools you always need ---
  packages = with pkgs; [
    # Git & VCS
    git
    gh # GitHub CLI

    # Common CLI utilities
    jq            # JSON processor
    yq            # YAML processor
    wget
    curl

    # Task/Build Runners
    task          # Go Task runner

    # Containerization
    docker-buildx # Docker Buildx
    docker-client # Docker CLI

    # Cloud CLIs
    awscli        # AWS CLI

    # IaC Tools
    opentofu      # OpenTofu
    tenv          # Tenv for Tofu/Terraform version management
    terraform-docs # Generate docs from Tofu/Terraform modules

    # Code Quality & Formatting
    pre-commit    # Universal pre-commit hook manager
    shellcheck    # Shell script linter
    shfmt         # Shell script formatter
    hadolint      # Dockerfile linter
    markdownlint-cli # Markdown linter

    # Release Tools
    git-chglog    # Changelog generator
    goreleaser    # Go Release automation
    svu           # Semantic Version Util

    # Nix specific tools
    nixpkgs-fmt   # Nix formatter
    niv           # Nix package manager for stable Nix environments (if not using flakes)
  ];

  # --- Environment variables (global for your dev) ---
  env = {
    # Example: A default AWS region if not overridden by project
    # AWS_DEFAULT_REGION = "us-east-1";
    GITHUB_TOKEN = $(gh auth token);
  };

  # --- Commands (global helper scripts) ---
  commands = {
    "setup" = ''
      echo "Running global devenv setup..."
      # Ensure pre-commit is installed for any repo
      pre-commit install || true
    '';
    "refresh-devenv" = ''
      echo "Refreshing global devenv. Run 'devenv up' from your global devenv directory."
    '';
  };

  # --- Hooks (global environment setup) ---
  enterShell = ''
    echo "Entering devenv shell!"
  '';

  # You can still use services if you want to run things like databases inside of the global devenv
  # services = {
  #   postgresql.enable = true;
  # };
}