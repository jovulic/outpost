{
  config,
  lib,
  ...
}:
let
  cfg = config.outpost.steam;
in
with lib;
{
  options = {
    outpost.steam = {
      enable = mkOption {
        type = types.bool;
        description = "Enable steam configuration.";
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
    };

    # https://wiki.nixos.org/wiki/GameMode
    # steam > gamemoderun %command%
    programs.gamemode = {
      enable = true;
    };

    environment.systemPackages = [
      pkgs.protontricks # a simple wrapper for running winetricks commands for proton-enabled games
      pkgs.protonup-qt # install and manage proton-ge for steam
    ];
  };
}
