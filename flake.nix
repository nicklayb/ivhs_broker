{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        systemSpecificDeps = if pkgs.stdenv.hostPlatform.isLinux then [ pkgs.inotify-tools ] else [ ];
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.beam28Packages.elixir_1_20
            pkgs.beam28Packages.erlang
            pkgs.beam28Packages.elixir-ls
            pkgs.beam28Packages.expert
            pkgs.direnv
            pkgs.just
            pkgs.tailwindcss_4
            pkgs.esbuild
            pkgs.nodejs_24
          ]
          ++ systemSpecificDeps;

          shellHook = ''
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex

            export TAILWIND_PATH=${pkgs.tailwindcss_4}/bin/tailwindcss
            export ESBUILD_PATH=${pkgs.esbuild}/bin/esbuild

            eval "$(direnv hook bash)"
            direnv allow
            mix deps.get
          '';
        };
      }
    );
}
