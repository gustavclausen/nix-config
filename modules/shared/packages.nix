{
  pkgs,
  agenix,
}:
with pkgs; [
  act
  age
  age-plugin-yubikey
  alacritty
  alejandra
  aws-vault
  awscli2
  bash-completion
  bashInteractive
  bruno
  cargo
  colima
  corepack_22
  coreutils
  diffutils
  docker
  docker-compose
  doggo
  eza
  findutils
  fzf
  gh
  gnumake
  gnupg
  gnused
  go
  gopls
  goreleaser
  gzip
  inetutils
  jq
  killall
  lazygit
  mkdocs
  neovim
  nodejs_22
  openssh
  openssl
  pre-commit
  python3
  ranger
  ripgrep
  ripgrep
  shellcheck
  tmux
  tree
  wget
  xz
  yq-go
  yubikey-manager
  zip
  zlib
] ++ [agenix.packages.${pkgs.system}.default]
