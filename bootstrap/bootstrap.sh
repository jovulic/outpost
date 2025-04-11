# shellcheck shell=bash

set -veuo pipefail

# Clearing data on /dev/nvme0n1...
wipefs -a /dev/nvme0n1
dd if=/dev/zero of=/dev/nvme0n1 bs=512 count=10000

# Creating paritions...
sfdisk /dev/nvme0n1 <<EOF
label: gpt
device: /dev/nvme0n1
unit: sectors
1 : size=4096 type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
2 : size=512MiB type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
3 : type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
EOF

# Configuring luks key...
dd if=/dev/urandom of=/dev/nvme0n1p1 bs=4096 count=1

# Configuring boot partition...
mkfs.fat /dev/nvme0n1p2 -F 32 -n boot

# Configuring root parition...
cryptsetup luksFormat /dev/nvme0n1p3 --key-file=/dev/nvme0n1p1 --keyfile-size=4096
cryptsetup open /dev/nvme0n1p3 cryptroot --key-file=/dev/nvme0n1p1 --keyfile-size=4096
pvcreate /dev/mapper/cryptroot
vgcreate pool /dev/mapper/cryptroot
lvcreate -l '100%FREE' -n root pool
mkfs.ext4 /dev/pool/root -L root

# Configuring WiFI...
# We cheat here slightly by (safely) assuming the network id generataed from
# add_network will be zero. We can improve this by properly parsing this out.
systemctl start wpa_supplicant
sleep 10
wpa_cli add_network
network_id=0
wpa_cli set_network "$network_id" ssid '"@wifi_ssid@"'
wpa_cli set_network "$network_id" psk '"@wifi_psk@"'
wpa_cli enable_network "$network_id"
sleep 20

# Mounting partitions and installing NixOS...
mkdir -p /mnt
mount /dev/pool/root /mnt

mkdir -p /mnt/boot
mount /dev/nvme0n1p2 /mnt/boot

nixos-generate-config --root /mnt
mv /mnt/etc/nixos/configuration.nix /mnt/etc/nixos/configuration-original.nix
cat >/mnt/etc/nixos/configuration.nix <<EOF
{ config, pkgs, lib, ... }:
{
  imports = [
    ./configuration-original.nix
    ./hardware-configuration.nix
  ];
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  boot = {
    initrd.luks.devices.luksroot = {
      device = "/dev/nvme0n1p3";
      allowDiscards = true;
      keyFileSize = 4096;
      keyFile = "/dev/nvme0n1p1";
    };
  };
  fileSystems."/" = lib.mkForce {
    device = "/dev/disk/by-label/root";
    fsType = "ext4";
  };
  fileSystems."/boot" = lib.mkForce {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
  networking = {
    hostName = "outpost";
  };
  users.users.root = {
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGdXDo+F2+TVAwH3CLJnK2SUIJR/6HvBeHEcfQbYxjk cardno:17_742_648" ];
  };
  services.openssh.enable = true;
  services.getty.autologinUser = "root";
}
EOF
nixos-install --no-root-passwd --option experimental-features 'nix-command flakes'

# Rebooting...
umount /mnt/boot /mnt
shutdown -r +2
