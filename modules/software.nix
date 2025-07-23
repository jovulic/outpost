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
      networkmanager = {
        enable = true;
        ensureProfiles.profiles = {
          "_" =
            let
              ssid = builtins.shell "gopass show -o --nosync wifi | jq -cr '.ssid'";
              psk = builtins.shell "gopass show -o --nosync wifi | jq -cr '.psk'";
            in
            {
              connection = {
                id = ssid;
                type = "wifi";
              };
              wifi = {
                mode = "infrastructure";
                ssid = ssid;
              };
              wifi-security = {
                auth-alg = "open";
                key-mgmt = "wpa-psk";
                psk = psk;
              };
              ipv4 = {
                method = "auto";
              };
              ipv6 = {
                addr-gen-mode = "default";
                method = "auto";
              };
            };
        };
      };

      firewall = {
        enable = true;
        allowedUDPPortRanges = [
          # https://larian.com/support/faqs/multiplayer-issues_84
          # lsof -i | grep bg3
          {
            from = 23253;
            to = 23262;
          }
          {
            from = 23243;
            to = 23252;
          }
        ];
      };
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
        options = "terminate:ctrl_alt_bksp,numpad:mac";
      };
    };

    # Enable CUPS to support printing.
    services.printing.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
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
      extraGroups = [
        "networkmanager"
      ];
      initialPassword = "password";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGdXDo+F2+TVAwH3CLJnK2SUIJR/6HvBeHEcfQbYxjk cardno:17_742_648"
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

    # Enable SSH and add authorized keys.
    services.openssh.enable = true;
    users.users.root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGdXDo+F2+TVAwH3CLJnK2SUIJR/6HvBeHEcfQbYxjk cardno:17_742_648"
      ];
    };

    system.stateVersion = "24.11";
  };
}
