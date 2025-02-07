{
  description = "Cardinal - An Enterprise identity platform built using Rust and Ory Kratos+Keto";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
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
              docker-compose
              lazydocker
              # Added tools for working with Kratos and Keto
              jq
              sqlx-cli
              # Development tools
              pgcli
            ]);
            nativeBuildInputs = commonNativeBuildInputs;
            # Environment variables for local development
            shellHook = ''
              echo "🦀 Cardinal Development Shell"
              
              # Kratos environment variables
              export KRATOS_ADMIN_URL="http://127.0.0.1:4434"
              export KRATOS_PUBLIC_URL="http://127.0.0.1:4433"
              
              # Keto environment variables
              export KETO_READ_URL="http://127.0.0.1:4466"
              export KETO_WRITE_URL="http://127.0.0.1:4467"
              
              export PGUSER=cardinal
              export PGPASSWORD=cardinal
              export PGDATABASE=cardinal
              export PGHOST=localhost
              export PGPORT=5432
              
              # Development environment
              export RUST_LOG="debug"
            '';
          };
        in
        {
          packages = {
            default = cardinal;
            cardinal = cardinal;
          };
          devShells.default = devShell;
        };
    };
}
