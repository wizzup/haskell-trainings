# shell.nix for nix-shell
# Overrideable ghc version by passing `compiler` argument
# Example:
# $ nix-shell shell.nix --argstr compiler ghc7103
#
# To list avaliable ghc version:
# $ nix-env -qaPA nixos.haskell.compiler

{ pkgs ? import <nixpkgs> {}, compiler ? "default" }:

with pkgs;

with (if compiler == "default"
        then haskellPackages
        else haskell.packages.${compiler});

let
  ghc = ghcWithPackages (ps: with ps; [
          random
        ]);

  tex = texlive.combine {
  inherit (texlive)
    scheme-small

    fdsymbol
    floatflt
    soul
    wasy
    wasysym
    ;
  };

  yanone-fonts-src = fetchzip {
    url = https://www.yanone.de/2015/data/UIdownloads/Yanone%20Kaffeesatz.zip;
    sha256 = "11hakl6j8gmjbapiyfik2jhasljgbqhsljzmygfbzvq9fpph287k";
  };

  yanone-fonts = stdenv.mkDerivation {
    name = "yanone-fonts";
    src = yanone-fonts-src;
    buildInputs = [ fontconfig ];
    phase = ["installPhase"];
    installPhase = ''
      mkdir -p $out/share/fonts/opentype
      cp -rv ${yanone-fonts-src}/* $out/share/fonts/opentype
    '';
  };

in
  mkShell {
    name = "hs-train";

    buildInputs = [
      tex
      yanone-fonts

      ghc cabal-install
    ];

    # https://github.com/NixOS/nixpkgs/issues/24485#issuecomment-290758573
    FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ yanone-fonts ]; };

    shellHook = ''
      eval "$(egrep ^export "$(type -p ghc)")"
      export PS1="\[\033[1;32m\][$name:\W]\n$ \[\033[0m\]"
    '';
  }
