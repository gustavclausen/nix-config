{pkgs}: {
  extraUserPackages = with pkgs; [
    alacritty
    aws-vault
    awscli2
    colima
    eksctl
    helm-docs
    helmfile
    opentofu
    terraform-docs
  ];
}
