{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    zephyr.url = "github:zmkfirmware/zephyr/v3.5.0+zmk-fixes";
    zephyr.flake = false;

    zephyr-nix = {
      url = "github:urob/zephyr-nix";
      inputs.zephyr.follows = "zephyr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zephyr-nix, ... }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        zephyr = zephyr-nix.packages.${system};
        # keymap_drawer = pkgs.python3Packages.callPackage ./nix/keymap-drawer.nix {};
      in {
        default = pkgs.mkShellNoCC {
          packages =
            [
              zephyr.pythonEnv
              (zephyr.sdk-0_16.override {targets = ["arm-zephyr-eabi"];})

              pkgs.cmake
              pkgs.dtc
              pkgs.ninja

              pkgs.just
              pkgs.yq 

              # keymap_drawer
            ];

          shellHook = ''
            export ZMK_BUILD_DIR=$(pwd)/.build;
            export ZMK_SRC_DIR=$(pwd)/zmk/app;
            export Zephyr_DIR=$(pwd)/zephyr;
          '';
        };
      }
    );
  };
}
