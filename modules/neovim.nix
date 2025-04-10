{
  config,
  lib,
  ...
}:
let
  cfg = config.outpost.neovim;
in
with lib;
{
  options = {
    outpost.neovim = {
      enable = mkOption {
        type = types.bool;
        description = "Enable neovim configuration.";
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
    };
  };
}
