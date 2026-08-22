{
  description = "Homelab - Redo";
  # References:
  # https://github.com/neonvoidx/nix

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    impermanence.url = "github:nix-community/impermanence";

    # flake-file.url = "github:vic/flake-file";
    # flake-parts.url = "github:hercules-ci/flake-parts";
    # import-tree.url = "github:vic/import-tree";
    # nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    
  };

  # outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
  outputs = {
    self,
    nixpkgs,
    impermanence,
    disko,
    ...
  } @ inputs: {
    # NixOS configuration entrypoint
    # nix run github:nix-community/nixos-anywhere -- --flake .#lilith-server --generate-hardware-config nixos-facter facter.json <hostname>
    nixosConfigurations = {
      lilith-server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit self inputs; };
        modules = [
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence

          ./host/server/lilith-server.nix
          { hardware.facter.reportPath = (builtins.pathExists ./facter.json ./facter.json) ? ./facter.json: null; }
        ];
      };
    };
  };
}
