{
  description = "NixOS configuration - Colmena First (rababou)";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.flake-utils.follows = "flake-utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    inputs@{
      self,
      flake-utils-plus,
      colmena,
      ...
    }:
    let
      system = "x86_64-linux";

      baseFlake = flake-utils-plus.lib.mkFlake {
        inherit self inputs;
        supportedSystems = [ system ];
        channelsConfig.allowUnfree = true;
        channels = {
          nixpkgs.input = inputs.nixpkgs;
          unstable.input = inputs.nixpkgs-unstable;
          master.input = inputs.nixpkgs-master;
        };

        outputsBuilder = channels: {
          formatter = channels.nixpkgs.nixfmt-tree;
        };
      };
    in
    baseFlake
    // {
      colmenaHive = colmena.lib.makeHive {
        meta = {
          inherit (self.pkgs.${system}) nixpkgs;

          specialArgs = {
            pkgs-unstable = self.pkgs.${system}.unstable;
            pkgs-master = self.pkgs.${system}.master;
            inherit inputs;
          };
        };

        defaults = {
          imports = [
            inputs.sops-nix.nixosModules.sops
            inputs.home-manager.nixosModules.home-manager
            inputs.nix-index-database.nixosModules.default
            inputs.disko.nixosModules.disko
            ./modules
          ];
          deployment.targetUser = null;
        };

        rababou = {
          imports = [ ./machines/rababou ];
        };
      };

      # Export Colmena nodes to standard nixosConfigurations
      nixosConfigurations = self.colmenaHive.nodes;
    };
}
