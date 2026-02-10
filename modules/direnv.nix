{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.direnv;
in
with lib;
{
  options = {
    forge.system.direnv = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable direnv configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
  };
}
