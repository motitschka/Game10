{
  description = "Game10: a console-style game library for Nintendo and Sony Systems on Linux";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      cargoToml = lib.importTOML ./Cargo.toml;
      # The libretro Cores Game10 downloads are built for ordinary distributions and need these
      # libraries, which NixOS doesn't have in /usr/lib. Linking them into Game10 loads them when it
      # starts, so a Core finds them already loaded. glibc's own libraries need nothing extra.
      coreLibs = [ "stdc++" "gcc_s" "gomp" "z" "GL" ];
    in
    {
      packages.${system}.default = pkgs.rustPlatform.buildRustPackage {
        pname = "game10";
        inherit (cargoToml.package) version;
        src = lib.cleanSource self;
        cargoLock.lockFile = ./Cargo.lock;

        nativeBuildInputs = [ pkgs.pkg-config pkgs.makeWrapper pkgs.copyDesktopItems ];
        buildInputs = [ pkgs.sdl3 pkgs.sdl3-ttf pkgs.zlib pkgs.libGL ];
        RUSTFLAGS = lib.concatMapStringsSep " " (arg: "-C link-arg=${arg}") (
          [ "-Wl,--push-state,--no-as-needed" ] ++ map (l: "-l${l}") coreLibs ++ [ "-Wl,--pop-state" ]
        );

        # Game10 finds its font with fontconfig's fc-match.
        postInstall = ''
          wrapProgram $out/bin/game10 --prefix PATH : ${lib.makeBinPath [ pkgs.fontconfig ]}
        '';

        desktopItems = [
          (pkgs.makeDesktopItem {
            name = "game10";
            desktopName = "Game10";
            comment = "Play your Nintendo and Sony games";
            exec = "game10";
            categories = [ "Game" "Emulator" ];
          })
        ];

        meta = {
          description = "Console-style game library for Nintendo and Sony Systems";
          homepage = "https://github.com/motitschka/Game10";
          license = lib.licenses.gpl3Plus;
          mainProgram = "game10";
          platforms = [ "x86_64-linux" ];
        };
      };
    };
}
