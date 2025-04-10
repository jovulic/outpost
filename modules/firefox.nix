{
  config,
  lib,
  ...
}:
let
  cfg = config.outpost.firefox;
in
with lib;
{
  options = {
    outpost.firefox = {
      enable = mkOption {
        type = types.bool;
        description = "Enable firefox configuration.";
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.firefox.enable = true;
  };
}
