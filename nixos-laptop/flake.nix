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

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = {
    nixpkgs,
    agenix,
    disko,
    impermanence,
    home-manager,
    nixvim,
    zen-browser,
    ...
  }@inputs:
    {
      nixosConfigurations.lilith = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        specialArgs = {
          inherit inputs;
        };

        modules = [
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
                  nixvim.homeModules.nixvim
                  zen-browser.homeModules.beta
                  ./home.nix
                ];
              };
            };
          }
          ./configuration.nix

          { hardware.facter.reportPath = ./facter.json; }
        ];
      };
    };
}
	
