{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.outpost.tools;
in
with lib;
{
  options = {
    outpost.tools = {
      enable = mkOption {
        type = types.bool;
        description = "Enable tools configuration.";
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.zip # compressor/archiver for creating and modifying zipfiles
      pkgs.unzip # extraction utility for archives compressed in .zip format
      pkgs.tmux # terminal multiplexer
    ];
  };
}
