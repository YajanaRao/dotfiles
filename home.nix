
{ config, pkgs, ... }:

{
  home.username = "yajanarao";
  home.homeDirectory = "/Users/yajanarao";

  home.stateVersion = "2.92.0"; # or your current nix version

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
