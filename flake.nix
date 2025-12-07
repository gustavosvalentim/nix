{
  description = "Nix configuration by gsv1s";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, ... }:
    let
      username = "gsv";

    in {
      darwinConfigurations = {
        # MacBook-Pro is the hostname
        "MacBook-Pro" = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./common
            ./systems/aarch64-darwin
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit username; };
                useGlobalPkgs = true;
                useUserPackages = true;
                users.gsv = import ./systems/aarch64-darwin/home.nix;
              };
            }
          ];
          specialArgs = { inherit inputs self username; };
        };
      };
    };
}
