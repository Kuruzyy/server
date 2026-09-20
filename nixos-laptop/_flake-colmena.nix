{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, colmena, home-manager, impermanence, disko, agenix, ... }@inputs:
    let
      system = "x86_64-linux";

      lilithModules = [
        ./configuration.nix

        { hardware.facter.reportPath = ./facter.json; }

        agenix.nixosModules.default
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        home-manager.nixosModules.home-manager

        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            users.lilith = {
              imports = [
                ./home.nix
              ];
            };
          };
        }
      ];
    in
    {
      #
      # Canonical NixOS configuration.
      #
      nixosConfigurations.lilith =
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = lilithModules;
        };

      #
      # Colmena deployment.
      #
      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            inherit system;
          };
        };

        lilith = {
          deployment = {
            targetHost = "192.168.1.238";
            targetUser = "root";
          };

          imports = lilithModules;
        };
      };
    };
}
