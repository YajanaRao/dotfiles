
{ config, pkgs, ... }:

{
  home.username = "yajana";
  home.homeDirectory = "/Users/yajana";

  home.stateVersion = "2.92.0"; # or your current nix version

  programs.home-manager.enable = true;

  # Import your module configurations
  imports = [
    ./modules/neovim.nix
    ./modules/nushell.nix
  ];
}
