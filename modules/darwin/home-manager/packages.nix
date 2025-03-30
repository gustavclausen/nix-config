{pkgs}:
with pkgs; [
  curl
  gawk
  (pkgs.writeShellScriptBin "gsed" "exec ${pkgs.gnused}/bin/sed \"$@\"")
  darwin.trash
  reattach-to-user-namespace
  (pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];})
]
