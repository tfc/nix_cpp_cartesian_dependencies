{
  nixpkgs ? import ./nixpkgs.nix,
  pkgs ? import nixpkgs {}
}:

let
  compilers = with pkgs; {
    gcc7 = stdenv;
    gcc8 = overrideCC stdenv gcc8;
    clang7 = overrideCC stdenv clang_7;
    clang8 = overrideCC stdenv clang_8;
  };

  pocoLibs = {
    poco190 = pkgs.poco;
    poco191 = pkgs.poco.overrideAttrs (oldAttrs: {
      name = "poco-1.9.1";
      src = pkgs.fetchzip {
        url = "https://github.com/pocoproject/poco/archive/poco-1.9.1.zip";
        sha256 = "0d5d6cxv5k0r0kcr2zjsxzjbpd8s1x8dmwzsjh04yq470i8jw9zz";
      };
    });
  };

  boostLibs = {
    inherit (pkgs) boost166 boost167 boost168 boost169;
  };

  originalDerivation = [ (pkgs.callPackage (import ./derivation.nix) {}) ];

  f = libname: libs: derivs: with pkgs.lib;
    concatMap (deriv:
      mapAttrsToList (libVers: lib:
        (deriv.override { "${libname}" = lib; }).overrideAttrs
          (old: { name = "${old.name}-${libVers}"; })
      ) libs
    ) derivs;

  overrides = [
    (f "stdenv" compilers)
    (f "poco"   pocoLibs)
    (f "boost"  boostLibs)
  ];
in
  pkgs.lib.foldl (a: b: a // { "${b.name}" = b; }) {} (
    pkgs.lib.foldl (a: f: f a) originalDerivation overrides
  )
