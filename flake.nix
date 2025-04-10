{
  description = "A single machine provisioned remotely via Nix.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
  };

  outputs =
    { ... }@inputs:
    let
      inherit (inputs) nixpkgs;
      inherit (inputs.nixpkgs) lib;
      systems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      eachSystem =
        f:
        lib.genAttrs systems (
          system:
          f {
            pkgs = nixpkgs.legacyPackages.${system};
            inherit system;
          }
        );
    in
    {
      devShells = eachSystem (
        { pkgs, ... }:
        {
          default =
            let
              ctl =
                with pkgs;
                writeShellApplication {
                  name = "ctl";
                  text = with builtins; readFile ./ctl/ctl;
                };
            in
            pkgs.mkShell {
              packages = [
                pkgs.git
                pkgs.bash
                pkgs.bashly
                ctl
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
                ./modules
                {
                  outpost.bootstrap.enable = true;
                  system.stateVersion = lib.trivial.release;
                }
              ];
            }).config.system.build.isoImage;
        }
      );
    };
}
