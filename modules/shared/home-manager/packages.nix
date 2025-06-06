{
  pkgs,
  agenix,
  ...
}:
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
    tree
    wget
    xz
    yq-go
    yubikey-manager
    zip
    zlib
  ]
  ++ [agenix.packages.${pkgs.system}.default]
