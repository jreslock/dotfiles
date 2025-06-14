{ config, pkgs, ... }:

{
  home = {
    stateVersion = "25.05";
    
    activation = {
      backupFileExtension = "backup";
    };
    
    file.".zshrc".source = ./zsh/.zshrc;
    file.".p10k.zsh".source = ./zsh/.p10k.zsh;
    packages = with pkgs; [
      antidote
      curl
      gh
      jq
      yq
    ];
  };

  disabledModules = [ "services/mako.nix" ];

  # 🔗 XDG-based configs
  xdg.configFile."docker/config.json".source = ./docker/config.json;

  # 🐚 Zsh and Powerlevel10k
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "romkatv/powerlevel10k"; # Will load from $ZSH_CUSTOM/themes if present
    };
  };

  # 🧠 Git config
  programs.git = {
    enable = true;
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

      merge.tool = "code";
      mergetool.code.cmd = "code --wait \$MERGED";

      credential.helper = "/usr/local/share/gcm-core/git-credential-manager";
    };
  };
}
