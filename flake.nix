# {
#   description = "A very basic flake";
#
#   inputs = {
#     nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # We want to use packages from the binary cache
#     flake-utils.url = "github:numtide/flake-utils";
#     gitignore = { url = "github:hercules-ci/gitignore.nix"; flake = false; };
#   };
#
#   outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
#   flake-utils.lib.eachSystem [ "aarch64-darwin" ] (system: let
#     pkgs = nixpkgs.legacyPackages.${system};
#     gitignoreSrc = pkgs.callPackage inputs.gitignore { };
#   in rec {
#     packages.hello = pkgs.callPackage ./default.nix { inherit gitignoreSrc; };
#
#     legacyPackages = packages;
#
#     defaultPackage = packages.hello;
#
#     devShell = pkgs.mkShell {
#       CARGO_INSTALL_ROOT = "${toString ./.}/.cargo";
#
#       buildInputs = with pkgs; [ cargo rustc git ];
#     };
#   });
# }
#


# {
#   description = "A simple cross-compiled Hello World for Raspberry Pi 4";
#
#   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
#
#   outputs = { self, nixpkgs }:
#     let
#       # Cross-compilation system configuration
#       crossSystem = (nixpkgs.lib.systems.elaborate { system = "aarch64-linux"; });
#       pkgs = import nixpkgs { system = "aarch64-darwin"; crossSystem = crossSystem; };
#     in
#     {
#       defaultPackage.aarch64-linux = pkgs.stdenv.mkDerivation {
#         name = "hello-world-rpi";
#
#         src = ./.;
#
#         buildInputs = with pkgs; [ rustc cargo ];
#
#         buildPhase = ''
#           cargo build
#         '';
#
#         installPhase = ''
#           install -D playwav $out/bin/playwav
#         '';
#       };
#     };
# }

# {
#   description = "A flake for building a Rust workspace using buildRustPackage.";
#
#   inputs = {
#     rust-overlay.url = "github:oxalica/rust-overlay";
#     flake-utils.follows = "rust-overlay/flake-utils";
#     nixpkgs.follows = "rust-overlay/nixpkgs";
#   };
#
#   outputs = inputs: with inputs;
#     flake-utils.lib.eachDefaultSystem (system:
#       let
#         pkgs = nixpkgs.legacyPackages.${system};
#         code = pkgs.callPackage ./. { inherit nixpkgs system rust-overlay; };
#       in rec {
#         packages = {
#           app = code.app;
#           wasm = code.wasm;
#           all = pkgs.symlinkJoin {
#             name = "all";
#             paths = with code; [ app wasm ];
#           };
#         default = packages.all;
#         };
#       }
#     );
# }
#


# {
#   description = "Cross-compiled Rust program for the Raspberry Pi 4B";
#
#   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
#
#   outputs = { self, nixpkgs }:
#     let
#       # Cross-compilation system configuration
#       crossSystem = (nixpkgs.lib.systems.elaborate { system = "aarch64-linux"; });
#       pkgs = import nixpkgs { system = "aarch64-darwin"; crossSystem = crossSystem; };
#     in
#     {
#       defaultPackage.aarch64-linux = pkgs.stdenv.mkDerivation {
#         name = "my-rust-project";
#
#         src = ./.;
#
#         nativeBuildInputs = with pkgs; [ rustc cargo ];
#
#         buildPhase = ''
#           export CARGO_HOME=$(mktemp -d)
#           export CARGO_TARGET_DIR=target
#           cargo build --target=aarch64-unknown-linux-gnu
#         '';
#
#         installPhase = ''
#           install -D target/aarch64-unknown-linux-gnu/debug/my-rust-binary $out/bin/my-rust-binary
#         '';
#       };
#     };
# }

{
  description = "My cross-compilation project";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: {
    devShell.aarch64-darwin =
      let
        pkgs = import nixpkgs { };
        crossPkgs = import nixpkgs {
          crossSystem = (import nixpkgs.lib).systems.examples.aarch64-multiplatform;
        };
      in
      pkgs.mkShell {
        buildInputs = [
          pkgs.rustc
          pkgs.cargo
          crossPkgs.buildPackages.gcc
          crossPkgs.buildPackages.gcc-unwrapped
          crossPkgs.buildPackages.binutils
          crossPkgs.buildPackages.stdenv
          crossPkgs.alsaLib
          crossPkgs.libiconv
        ];
        shellHook = ''
          export PKG_CONFIG_ALLOW_CROSS=1
          export PKG_CONFIG_PATH=${crossPkgs.alsaLib}/lib/pkgconfig:${crossPkgs.libiconv}/lib/pkgconfig
          export TARGET_CC=${crossPkgs.buildPackages.gcc}/bin/aarch64-unknown-linux-gnu-gcc
        '';
      };
  };
}

