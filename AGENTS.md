# Project: Outpost

## Project Overview

This repository contains the NixOS configuration for a machine named "Outpost". The project is designed to allow for complete remote provisioning of the machine. It utilizes Nix Flakes to manage dependencies and configurations, and `deploy-rs` for remote deployment.

The provisioning process starts with a minimal bootstrap USB image that installs a base NixOS system. This base system is configured with networking and SSH access, allowing for subsequent deployments of the full system configuration remotely.

## Building and Running

This project uses `just` as a command runner. The main commands are:

- `just update`: Update the Nix Flake inputs to their latest versions.
- `just deploy`: Deploy the current NixOS configuration to the "Outpost" machine using `deploy-rs`.
- `just bootstrap device [mode=prompt]`: Build the bootstrap ISO image and write it to a specified USB device. This is used for the initial provisioning of the machine.

To enter a development shell with all the required tools, run:

```bash
nix develop
```

## Development Conventions

- **Nix Flakes:** The project is structured as a Nix Flake. All dependencies and configurations are managed through `flake.nix`.
- **`justfile`:** Common development and deployment tasks are defined in the `justfile`. Use `just` to see a list of available commands.
- **Modular Configuration:** The NixOS configuration is broken down into modules located in the `modules/` directory. Each module configures a specific aspect of the system (e.g., `firefox.nix`, `nvidia.nix`).

## Directory Overview

- `flake.nix`: The central file for the Nix Flake, defining inputs, outputs, and the overall structure of the project.
- `justfile`: Contains the `just` commands for building, deploying, and managing the project.
- `bootstrap/`: This directory contains the resources for building the initial bootstrap USB image.
  - `bootstrap.sh`: The main script that partitions the disk, sets up encryption, and installs the base NixOS system.
  - `README.md`: Provides an overview of the bootstrap process.
- `modules/`: This directory contains the NixOS modules that make up the main system configuration.
  - `default.nix`: Imports all the other modules in the directory.
  - Other `.nix` files: Each file configures a specific piece of software or hardware.
