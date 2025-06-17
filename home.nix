{ config, pkgs, ... }:

{
  home = {
    stateVersion = "25.11";
    file.".zshrc" = {
      source = ./zsh/.zshrc;
      force  = true;
    };
    file.".p10k.zsh" = {
      source = ./zsh/.p10k.zsh;
      force  = true;
    };
    packages = with pkgs; [
      antidote
      awscli2
      curl
      direnv
      gh
      home-manager
      jq
      nix-direnv
      wget
      yq
      
      # IaC Tools
      opentofu
      tenv
      terraform-docs

      # Containerization
      docker-buildx
      docker-client

      # Build and Task Automation
      go-task

      # Git and Release Management Tools
      git
      git-chglog
      goreleaser
      svu

      # Code Quality & Formatting
      pre-commit
      shellcheck
      shfmt
    ];
  };

  # 🔗 XDG-based configs
  xdg.configFile."docker/config.json" = {
    source = ./docker/config.json;
    force  = true;
  };

  programs.home-manager.enable = true;

  # 🐚 Zsh and Powerlevel10k
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme  = "romkatv/powerlevel10k";
    };
  };

  # 🧠 Git config
  programs.git = {
    enable    = true;
    userName  = "Jason Reslock";
    userEmail = "jreslock@users.noreply.github.com";

    extraConfig = {
      core = {
        editor = "code --wait --new-window";
        pager  = "less -F";
      };

      color.ui = "auto";
      push.default = "current";

      pull = {
        rebase = true;
        ff     = "only";
      };

      fetch.prune = true;

      alias.ignore = "!gi() { curl -L -s https://www.gitignore.io/api/$@ ;}; gi";

      diff.tool = "code";

      difftool.vscode = {
        cmd  = "code --wait --diff \$LOCAL \$REMOTE";
        tool = "code";
      };

      merge.tool         = "code";
      mergetool.code.cmd = "code --wait \$MERGED";

      credential.helper = "gh";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  disabledModules = [ "services/mako.nix" ];
}
