{ config, pkgs, ... }:

{
  home.stateVersion = "24.05";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh.enable = true;
    shellAliases = {
      ll = "ls -la";
    };
  };

  home.file.".zshrc".source = ./zsh/.zshrc;
}
