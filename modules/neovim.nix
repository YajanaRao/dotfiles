{ config, pkgs, dotfilesRoot, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [ tree-sitter lua-language-server ];
  };

  # Sync config from your dotfiles repo
}
