{ inputs, pkgs, ... }:
{
  packages = with pkgs; [
    git
    sops
    ssh-to-age
    disko
    nixos-anywhere
    inputs.colmena.packages.${pkgs.system}.colmena
  ];

  languages.nix.enable = true;

  git-hooks.hooks = {
    actionlint.enable = true;
    nixfmt.enable = true;
    deadnix = {
      enable = true;
      settings.edit = true;
    };
    statix.enable = true;
  };
}
