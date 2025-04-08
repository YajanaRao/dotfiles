{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [ tree-sitter lua-language-server ];
  };

  # Sync config from your dotfiles repo
  home.file.".config/nvim".source = ../config/nvim;
}
