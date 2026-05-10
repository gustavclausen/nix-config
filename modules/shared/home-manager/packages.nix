{
  pkgs,
  agenix ? null,
  ...
}:
let
  agenixPackage =
    if agenix == null then [ ] else [ agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
in
with pkgs;
[
  age
  age-plugin-yubikey
  bash-completion
  bashInteractive
  coreutils
  diffutils
  doggo
  findutils
  gnumake
  gnused
  gzip
  inetutils
  just
  killall
  openssh
  openssl
  parallel
  python3
  ripgrep
  tree
  wget
  xz
  yq-go
  yubikey-manager
  zip
  zlib
]
++ agenixPackage
