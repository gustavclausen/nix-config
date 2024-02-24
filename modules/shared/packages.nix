{pkgs}:
with pkgs; [
  alacritty
  bash-completion
  coreutils
  killall
  openssh
  wget
  zip
  jq
  tree
  yq
  tmux
  neovim
  alejandra
  ripgrep
  (nerdfonts.override
    {fonts = ["JetBrainsMono"];})
  lazygit

  age
  gnupg
  age-plugin-yubikey
  yubikey-manager

  docker
  docker-compose
  kubeswitch
  kubectl
  helmfile

  go
  gopls
  nodejs_21
  cargo
  python3

  awscli2
  bashInteractive
  colima
  curl
  diffutils
  findutils
  fzf
  gawk
  gh
  gzip
  k6
  k9s
  gnumake
  mkdocs

  helm-docs
  poetry
  pre-commit
  ranger
  redis
  ripgrep
  shellcheck
  inetutils
  terraform-docs
  terraform
  tflint
  gnused
]
