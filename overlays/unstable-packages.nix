{ nixpkgs-unstable }:
final: prev:
let
  unstable = import nixpkgs-unstable { inherit (final) system config; };
in
{
  claude-code = unstable.claude-code;
  codex = unstable.codex;
  colima = unstable.colima;
  ctx7 = unstable.ctx7;
}
