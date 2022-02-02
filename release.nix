let
  sources = import ./nix/sources.nix { };
  pkgs = import sources.nixpkgs { };
  oldPkgs = import sources.nixpkgs-2105 { };

  default = pkgs.callPackage ./derivation.nix {};

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
      poco # this is 1.11.1 on the current nixpkgs pin
      (pkgs.callPackage oldPkgs.poco.override { }) # 1.10.1 in nixos 21.05
    ];
  };

  toKeyValue = input@{ stdenv, boost, poco }:
    let replDots = pkgs.lib.strings.replaceChars [ "." ] [ "_" ];
    in
    pkgs.lib.nameValuePair
      # just dropping the dots from version numbers because nix uses dots
      # to refer to describe paths into attribute trees
      "${replDots stdenv.cc.cc.name}-poco-${replDots poco.version}-boost-${replDots boost.version}"
      (default.override input);
in
{
  inherit default;
  variants = pkgs.recurseIntoAttrs (builtins.listToAttrs (builtins.map toKeyValue inputs));
}
