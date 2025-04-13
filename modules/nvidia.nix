{
  config,
  lib,
  ...
}:
let
  cfg = config.outpost.nvidia;
in
with lib;
{
  options = {
    outpost.nvidia = {
      enable = mkOption {
        type = types.bool;
        description = "Enable nvidia configuration.";
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
