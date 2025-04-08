
{ config, pkgs, ... }:

{
  home.username = "yajanarao";
  home.homeDirectory = "/Users/yajanarao";

  home.stateVersion = "24.11"; # or your current nix version
home.enableNixpkgsReleaseCheck = false;

  programs.home-manager.enable = true;


  # Add your packages
  programs.neovim.enable = true;
  programs.nushell.enable = true;

  # Import your module configurations
  imports = [
    ./modules/neovim.nix
    ./modules/nushell.nix
  ];
}
