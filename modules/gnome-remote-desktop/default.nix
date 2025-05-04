{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.outpost.remote;
in
with lib;
{
  options = {
    outpost.remote = {
      enable = mkOption {
        type = types.bool;
        description = "Enable remote configuration.";
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.gnome-remote-desktop
    ];
    # home=/var/lib/gnome-remote-desktop
    services.gnome.gnome-remote-desktop.enable = true;
    networking.firewall.allowedTCPPorts = [ 3389 ];
    networking.firewall.allowedUDPPorts = [ 3389 ];

    environment.etc."gnome-remote-desktop/tls.crt".source = ./tls.crt;
    environment.etc."gnome-remote-desktop/tls.key".source = ./+tls.key;
    systemd.services.gnome-remote-desktop = {
      description = "Gnome Remote Desktop system configuration.";
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.gnome-remote-desktop
        pkgs.freerdp # winpr-makecert
        pkgs.polkit
      ];
      serviceConfig = {
        ExecStartPre = lib.mkBefore ''
          ${pkgs.gnome-remote-desktop}/bin/grdctl --system rdp set-tls-key /var/lib/gnome-remote-desktop/tls.key
          ${pkgs.gnome-remote-desktop}/bin/grdctl --system rdp set-tls-cert /var/lib/gnome-remote-desktop/tls.crt
        '';
      };
    };

    # NB: This assumes the only user present is "scout".
    # TODO: Do not believe this actually works, but it would be nice if
    # something like this did work.
    systemd.user.services.gnome-remote-desktop-scout = {
      description = "Gnome Remote Desktop scout configuration.";
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          let
            password = builtins.shell "gopass show -o --nosync outpost.lan/scout/rdp";
          in
          ''
            ${pkgs.gnome-remote-desktop}/bin/grdctl rdp enable
            ${pkgs.gnome-remote-desktop}/bin/grdctl rdp set-credentials "scout" "${password}"
          '';
      };
    };

    security.polkit.enable = true; # Required by grdctl.
  };
}
