{
  config,
  lib,
  ...
}:
let
  cfg = config.outpost.software;
in
with lib;
{
  options = {
    outpost.software = {
      enable = mkOption {
        type = types.bool;
        description = "Enable software configuration.";
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };

    # Configure networking with...
    # - Set hostname.
    # - Enable network manager.
    networking = {
      hostName = "outpost";
      networkmanager.enable = true;
    };

    # Set timezone.
    time.timeZone = "America/Toronto";

    # Select internationalization properties.
    i18n.defaultLocale = "en_CA.UTF-8";

    # Configure xserver with...
    # - Set GNOME Desktop environment
    # - Set US keymap.
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    # Enable CUPS to support printing.
    services.printing.enable = true;

    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    # Setup user and enable auto-login.
    users.users.scout = {
      isNormalUser = true;
      initialPassword = "password";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
    services.displayManager.autoLogin = {
      enable = true;
      user = "scout";
    };
    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    # Allow unfree packages.
    nixpkgs.config.allowUnfree = true;

    system.stateVersion = "24.11";
  };
}
