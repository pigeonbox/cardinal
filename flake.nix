{
  description = "Cardinal - An Enterprise identity application built using Rust and EdgeDB";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-analyzer-src.follows = "";
    };
    
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, crane, fenix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = { config, system, pkgs, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          toolchain = fenix.packages.${system}.complete;
          craneLib = crane.lib.${system}.overrideToolchain toolchain;
          commonBuildInputs = with pkgs; [
            openssl.dev
            pkg-config
          ];

          commonNativeBuildInputs = with pkgs; [
            pkg-config
            protobuf
          ];

          cardinal = craneLib.buildPackage {
            pname = "cardinal";
            version = "0.1.0";
            src = craneLib.cleanCargoSource ./.;
            buildInputs = commonBuildInputs;
            nativeBuildInputs = commonNativeBuildInputs;
            OPENSSL_NO_VENDOR = true;
            RUST_BACKTRACE = 1;
            doCheck = false;
          };
          devShell = pkgs.mkShell {
            buildInputs = commonBuildInputs ++ (with pkgs; [
              toolchain.toolchain
              rust-analyzer
              cargo-watch
              cargo-audit
              cargo-outdated
              edgedb
              docker-compose 
            ]);

            nativeBuildInputs = commonNativeBuildInputs;

            shellHook = ''
              echo "🦀 Cardinal Development Shell"
              export RUST_LOG=debug
              export EDGEDB_HOST=localhost
              export EDGEDB_PORT=5656
            '';
          };

        in {
          packages = {
            default = cardinal;
            cardinal = cardinal;
          };
          devShells.default = devShell;
        };
    };
}
