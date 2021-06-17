{
  nixpkgs ? import ./nixpkgs.nix,
  pkgs ? import nixpkgs {}
}:

let
  inputs = pkgs.lib.cartesianProductOfSets {
    stdenv = with pkgs; [
      (overrideCC stdenv gcc9)
      (overrideCC stdenv gcc10)
      (overrideCC stdenv gcc11)
      (overrideCC clangStdenv clang_10)
      (overrideCC clangStdenv clang_11)
      (overrideCC clangStdenv clang_12)
    ];

    boost = with pkgs; [ boost173 boost174 boost175 ];

    poco = with pkgs; [
      poco
      (poco.overrideAttrs (oldAttrs: {
        pname = "poco";
        version = "1.9.1";
        src = pkgs.fetchgit {
          url = "https://github.com/pocoproject/poco.git";
          rev = "196540ce34bf884921ff3f9ce338e38fc938acdd";
          sha256 = "0q0xihkm2z8kndx40150inq7llcyny59cv016gxsx0vbzzbdkcnd";
        };
      }))
    ];
  };

  toKeyValue = input@{ stdenv, boost, poco }:
    let replDots = pkgs.lib.strings.replaceChars ["."] ["_"];
    in pkgs.lib.nameValuePair
      # just dropping the dots from version numbers because nix uses dots
      # to refer to describe paths into attribute trees
      "${replDots stdenv.cc.cc.name}-poco-${replDots poco.version}-boost${replDots boost.version}"
      (import ./derivation.nix input);
in

builtins.listToAttrs (builtins.map toKeyValue inputs)
