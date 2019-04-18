{ boost, poco, stdenv }:

stdenv.mkDerivation {
  name = "my-app";
  src = ./src;

  buildInputs = [ boost poco ];

  buildPhase = "c++ -std=c++17 -o main main.cpp -lPocoFoundation -lboost_system";

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp main $out/bin/
  '';
}
