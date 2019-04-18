{
  nixpkgs ? import ./nixpkgs.nix,
  pkgs ? import nixpkgs {}
}:

pkgs.callPackage (import ./derivation.nix) {}
