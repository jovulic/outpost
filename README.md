# Outpost

_A single machine provisioned remotely via Nix._

## 📌 Description

The repository contains Nix configuration related to my machine called "Outpost".

The machine is unique in that it can self-provision to a minimal base image and then otherwise expects further configuration to come from remote machines. Specifically, with no bootable disks, it will boot from a configured USB that configures a minimal system that has an static IP address and open SSH ports for authorized users. It will then wait for SSH connections that will contain further configuration from that base image.
