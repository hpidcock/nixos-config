{
  description = "hpidcock's nix on ubuntu flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable"; 
    home-manager.url = "github:nix-community/home-manager?ref=release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url = "github:nix-community/nixGL";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixgl, nix-vscode-extensions }: 

  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      system = system; 
      config = {
        allowUnfree = true;
      };
      overlays = [
        nixgl.overlay
      ];
    };
    unstable-pkgs = import nixpkgs-unstable {
      system = system;
      config = {
        allowUnfree = true;
      };
      overlays = [
        nix-vscode-extensions.overlays.default
      ];
    };
  in
  {
    homeConfigurations.hpidcock = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgs;
      modules = [
        ./home.nix
      ];
      extraSpecialArgs = {
        unstable-pkgs = unstable-pkgs;
      };
    };
  };
}
