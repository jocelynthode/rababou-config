{
  description = "NixOS configuration";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus/v1.5.1";
      inputs.flake-utils.follows = "flake-utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
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
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-master,
      home-manager,
      sops-nix,
      nix-index-database,
      disko,
      colmena,
      flake-utils-plus,
      ...
    }:
    let
      commonModules = [
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        nix-index-database.nixosModules.default
        disko.nixosModules.disko
        ./modules
      ];

      mkHostSpecialArgs = system: {
        pkgs-unstable = self.pkgs.${system}.unstable;
        pkgs-master = self.pkgs.${system}.master;
      };

      colmenaSystem = "x86_64-linux";
      mkColmenaSpecialArgs = system: {
        pkgs-unstable = self.pkgs.${system}.unstable;
        pkgs-master = self.pkgs.${system}.master;
      };
    in
    flake-utils-plus.lib.mkFlake {
      inherit self inputs;

      supportedSystems = [
        "x86_64-linux"
      ];

      channelsConfig.allowUnfree = true;

      channels = {
        nixpkgs.input = nixpkgs;
        unstable.input = nixpkgs-unstable;
        master.input = nixpkgs-master;
      };

      hostDefaults = {
        modules = commonModules;
      };

      outputsBuilder =
        channels:
        let
          pkgs = channels.nixpkgs;
        in
        {
          formatter = pkgs.nixfmt-tree;
        };

      hosts = {
        rababou = {
          modules = [
            ./machines/rababou
          ];
          specialArgs = mkHostSpecialArgs "x86_64-linux";
        };
      };
    }
    // {
      colmenaHive = colmena.lib.makeHive {
        meta = {
          inherit (self.pkgs.${colmenaSystem}) nixpkgs;
        };

        defaults = {
          _module.args = mkColmenaSpecialArgs colmenaSystem;
          imports = commonModules;
        };

        rababou = {
          imports = [
            ./machines/rababou
          ];
          deployment = {
            # use user in ssh config
            targetUser = null;
          };
        };
      };
    };
}
