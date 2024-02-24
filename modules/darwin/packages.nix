{
  pkgs,
  extra,
}:
with pkgs; let
  shared-packages = import ../shared/packages.nix {inherit pkgs;};
in
  shared-packages
  ++ extra
  ++ [
    curl
    gawk
    pinentry_mac
  ]
