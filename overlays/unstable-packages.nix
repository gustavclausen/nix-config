{ nixpkgs-unstable }:
final: prev:
let
  unstable = import nixpkgs-unstable {
    inherit (final) config;
    system = final.stdenv.hostPlatform.system;
  };
in
{
  claude-code = unstable.claude-code;
  codex = unstable.codex;
  colima = unstable.colima;
  ctx7 = unstable.ctx7;
  zed-editor = unstable.zed-editor;
}
