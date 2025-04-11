{
  config,
  lib,
  modulesPath,
  ...
}:
let
  cfg = config.outpost.hardware;
in
with lib;
{
  options = {
    outpost.hardware = {
      enable = mkOption {
        type = types.bool;
        description = "Enable hardware configuration.";
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    boot = {
      initrd = {
        luks.devices.luksroot = {
          device = "/dev/nvme0n1p3";
          allowDiscards = true;
          keyFile = "/dev/nvme0n1p1";
          keyFileSize = 4096;
        };
        availableKernelModules = [
          "xhci_pci"
          "thunderbolt"
          "nvme"
          "usbhid"
          "usb_storage"
          "sd_mod"
          "rtsx_pci_sdmmc"
        ];
        kernelModules = [ ];
      };
      kernelModules = [
        "intel-kvm"
      ];
      extraModulePackages = [ ];
    };

    fileSystems."/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    swapDevices = [ ];

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    hardware = {
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
  };
}
