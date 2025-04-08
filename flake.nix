{
  description = "Yajana's dotfiles managed with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations = {
      yajana = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin"; # or "x86_64-linux" if on Linux
        };
        modules = [
          ./home.nix
        ];
      };
    };
  };
}
