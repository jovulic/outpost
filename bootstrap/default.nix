{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.outpost.bootstrap;
in
with lib;
{
  options = {
    outpost.bootstrap = {
      enable = mkOption {
        type = types.bool;
        description = "Enable machine bootstrap.";
        default = false;
      };
    };
  };
  config =
    let
      bootstrap = pkgs.writeShellApplication {
        name = "bootstrap";
        text = builtins.readFile (
          pkgs.replaceVars ./bootstrap.sh {
            wifi_ssid = builtins.shell "gopass show -o --nosync wifi | jq -cr '.ssid'";
            wifi_psk = builtins.shell "gopass show -o --nosync wifi | jq -cr '.psk'";
          }
        );
      };
    in
    mkIf cfg.enable {
      systemd.services.setupsystem = {
        enable = true;
        wantedBy = [ "multi-user.target" ];
        after = [ "getty@tty1.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = [
            "${pkgs.bash}/bin/bash -c 'source ${config.system.build.setEnvironment}; ${bootstrap}/bin/bootstrap'"
          ];
          StandardInput = "null";
          StandardOutput = "journal+console";
          StandardError = "inherit";
        };
      };
    };
}
