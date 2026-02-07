{
  description = "A single machine provisioned remotely via Nix.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { ... }@inputs:
    let
      inherit (inputs) self nixpkgs deploy-rs;
      inherit (inputs.nixpkgs) lib;
      eachSystem =
        systemsOrF:
        if builtins.isList systemsOrF then
          f:
          nixpkgs.lib.genAttrs systemsOrF (
            system:
            f {
              pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
              };
              inherit system;
            }
          )
        else
          let
            defaultSystems = [
              "aarch64-linux"
              "aarch64-darwin"
              "x86_64-darwin"
              "x86_64-linux"
            ];
          in
          nixpkgs.lib.genAttrs defaultSystems (
            system:
            systemsOrF {
              pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
              };
              inherit system;
            }
          );
      # EXAMPLE:
      # devShells = eachSystem (
      #   { pkgs, ... }:
      #   {
      #     default = pkgs.mkShell {
      #       packages = [
      #         pkgs.git
      #         pkgs.bash
      #         pkgs.just
      #         pkgs.go
      #         pkgs.toybox
      #         pkgs.openssh
      #       ];
      #     };
      #   }
      # );
    in
    {
      devShells = eachSystem (
        { pkgs, system, ... }:
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.git
              pkgs.bash
              pkgs.just
              deploy-rs.packages.${system}.default
            ];
          };
        }
      );
      packages = eachSystem (
        { pkgs, system, ... }:
        {
          bootstrap =
            (nixpkgs.lib.nixosSystem {
              inherit pkgs system;
              modules = [
                "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                ./bootstrap
                {
                  outpost.bootstrap.enable = true;
                  system.stateVersion = lib.trivial.release;
                }
              ];
            }).config.system.build.isoImage;
        }
      );
      nixosConfigurations = {
        outpost = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (
              { modulesPath, ... }:
              {
                imports = [
                  (modulesPath + "/installer/scan/not-detected.nix")
                ];
              }
            )
            ./modules
            { }
          ];
        };
      };
      deploy = {
        nodes = {
          outpost = {
            hostname = "outpost.lan";
            profiles.system = {
              sshUser = "root";
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.outpost;
            };
          };
        };
      };
    };
}
