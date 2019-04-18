{
  nixpkgs ? import ./nixpkgs.nix,
  pkgs ? import nixpkgs {},
  passthroughDerivations ? true
}:
let
  derivations = import ./release.nix { inherit pkgs; };

  f = p: pkgs.runCommand "${p.name}-output" {} ''
    mkdir -p $out/nix-support
    ${p}/bin/main > $out/output.txt
    echo "report output $out output.txt" >> $out/nix-support/hydra-build-products
  '';

  outputs = with pkgs.lib;
    mapAttrs' (name: deriv:
      nameValuePair ("${name}-output") (f deriv)
    ) derivations;
in
  if passthroughDerivations then derivations else {} // outputs
