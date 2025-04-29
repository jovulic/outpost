{
  config,
  lib,
  ...
}:
let
  cfg = config.outpost.google-chrome;
in
with lib;
{
  options = {
    outpost.google-chrome = {
      enable = mkOption {
        type = types.bool;
        description = "Enable google-chrome configuration.";
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.google-chrome
    ];
  };
}
