{ pkgs, ... }:

{
  # --- REMOVED THE 'devenv.config' WRAPPER ---
  
  # Explicitly disable apple.sdk to avoid the missing apple-sdk error
  apple.sdk = null;
  
  languages = {
    python = { enable = true; };
    go = { enable = true; };
    # nodejs = { enable = true; };
    # rust = { enable = true; };
    # dotnet = { enable = true; };
    # ruby = { enable = true; };
  };

  packages = with pkgs; [
    # IaC Tools
    opentofu
    tenv
    terraform-docs

    # Containerization
    docker-buildx
    docker-client

    # Build and Task Automation
    go-task

    # General CLI Utilities
    jq
    yq
    wget
    curl

    # Git and Release Management Tools
    git-chglog
    goreleaser
    svu

    # Code Quality & Formatting
    pre-commit
    shellcheck
    shfmt

    # Cloud CLIs
    awscli2
  ];

  env = {
    # AWS_REGION = "us-east-1";
    # TASKFILE_DIR = "./tasks";
  };

  enterShell = ''
    echo "Now in devenv! (from dev-tools.nix)"
    pre-commit install || true
  '';
}
