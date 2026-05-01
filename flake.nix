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
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.beam28Packages.elixir_1_20
            pkgs.beam28Packages.erlang
            pkgs.beam28Packages.elixir-ls
            pkgs.direnv
            pkgs.inotify-tools
            pkgs.just
          ];

          shellHook = ''
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex
            eval "$(direnv hook bash)"
            direnv allow
            mix deps.get
          '';
        };
      }
    );
}
