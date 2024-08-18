{
  pkgs,
  extra,
  agenix,
}:
with pkgs; let
  shared-packages = import ../shared/packages.nix {inherit pkgs agenix;};
in
  shared-packages
  ++ extra
  ++ [
    curl
    gawk
    pinentry_mac
    (pkgs.writeShellScriptBin "gsed" "exec ${pkgs.gnused}/bin/sed \"$@\"")
    darwin.trash
  ]
