{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.outpost.remote-desktop;
in
with lib;
{
  options = {
    outpost.remote-desktop = {
      enable = mkOption {
        type = types.bool;
        description = "Enable remote-desktop configuration.";
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    # Issues getting gnome-remote-desktop working on NixOS.
    # The current work-around supports screen sharing but not remote login.
    #
    # https://github.com/NixOS/nixpkgs/issues/361163
    environment.systemPackages = [
      pkgs.gnome-remote-desktop
    ];
    security.polkit.enable = true; # Required by grdctl.

    # home=/var/lib/gnome-remote-desktop-desktop
    services.gnome.gnome-remote-desktop.enable = true;
    networking.firewall.allowedTCPPorts = [ 3389 ];
    networking.firewall.allowedUDPPorts = [ 3389 ];

    systemd.services.gnome-remote-desktop = {
      wantedBy = [ "graphical.target" ];
    };
  };
}
