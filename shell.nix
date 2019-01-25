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

    floatflt
    wasysym
    fdsymbol
    soul
    ;
  };

in mkShell {
  name = "hs-train";

  buildInputs = [
    tex
    ghc
  ];

  shellHook = ''
    eval "$(egrep ^export "$(type -p ghc)")"
    export PS1="\[\033[1;32m\][$name:\W]\n$ \[\033[0m\]"
    export GHCRTS='-M1G'
  '';
}
