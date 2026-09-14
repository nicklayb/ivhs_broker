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
    let
      nixosModule = import ./nixosModule.nix {
        inherit self;
      };
    in
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        tailwind = pkgs.tailwindcss_4;
        esbuild = pkgs.esbuild;
        erlangPackages = pkgs.beam28Packages;
        erlang = erlangPackages.erlang;
        elixir = erlangPackages.elixir_1_20;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            erlang
            elixir
            erlangPackages.expert
            pkgs.direnv
            pkgs.just
            tailwind
            esbuild
            pkgs.nodejs_24
          ]
          ++ (nixpkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.inotify-tools ]);

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
        packages.default =
          let
            version = "0.1.0";
            src = ./.;
            mixNixDeps = pkgs.callPackages ./deps.nix { };
            translatedPlatform =
              {
                aarch64-darwin = "macos-arm64";
                aarch64-linux = "linux-arm64";
                armv7l-linux = "linux-armv7";
                x86_64-darwin = "macos-x64";
                x86_64-linux = "linux-x64";
              }
              .${system};
          in
          erlangPackages.mixRelease {
            inherit version src mixNixDeps;
            pname = "ivhs-broker";

            postBuild = ''
              mix do deps.loadpaths --no-deps-check, phx.digest
            '';

            preInstall = ''
              ln -s ${tailwind}/bin/tailwindcss _build/tailwind-${translatedPlatform}
              ln -s ${esbuild}/bin/esbuild _build/esbuild-${translatedPlatform}

              ${elixir}/bin/mix do deps.loadpaths --no-deps-check, assets.deploy
              ${elixir}/bin/mix do deps.loadpaths --no-deps-check, phx.gen.release   
            '';
          };
      }
    ))
    // {
      nixosModules.default = nixosModule;
    };
}
