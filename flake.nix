{
  description = "hpidcock's nix on ubuntu flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-staging.url = "github:nixos/nixpkgs?ref=staging";
    nixpkgs-24-05.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    home-manager.url = "github:nix-community/home-manager?ref=release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url = "github:nix-community/nixGL";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    _1password-shell-plugins.url = "github:1Password/shell-plugins";
  };

  outputs = { nixpkgs, nixpkgs-unstable, nixpkgs-staging, nixpkgs-24-05, home-manager, nixgl
    , nix-vscode-extensions, ... }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = system;
        config = { allowUnfree = true; };
        overlays = [ nixgl.overlay ];
      };
      pkgs-unstable = import nixpkgs-unstable {
        system = system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "electron-27.3.11" ];
        };
        overlays = [ nixgl.overlay nix-vscode-extensions.overlays.default ];
      };
      pkgs-24-05 = import nixpkgs-24-05 {
        system = system;
        config = { allowUnfree = true; };
      };
      pkgs-staging = import nixpkgs-staging {
        system = system;
        config = { allowUnfree = true; };
      };
    in {
      homeConfigurations.hpidcock = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = {
          pkgs-unstable = pkgs-unstable;
          pkgs-24-05 = pkgs-24-05;
          pkgs-staging = pkgs-staging;
        };
      };
    };
}
