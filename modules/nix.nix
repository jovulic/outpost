{
  config,
  lib,
  ...
}:
let
  cfg = config.outpost.nix;
in
with lib;
{
  options = {
    outpost.nix = {
      enable = mkOption {
        type = types.bool;
        description = "Enable nix configuration.";
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
  };
}
