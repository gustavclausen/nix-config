{nixpkgs-unstable}: final: prev: {
  colima = (import nixpkgs-unstable {inherit (final) system config;}).colima;
}
