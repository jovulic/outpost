{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.outpost.xpra;
in
with lib;
{
  options = {
    outpost.xpra = {
      enable = mkOption {
        type = types.bool;
        description = "Enable xpra configuration.";
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.xpra
    ];
  };
}
