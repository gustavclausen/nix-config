{pkgs}: {
  extraUserPackages = with pkgs; [
    eksctl
    helm-docs
    helmfile
    k9s
    kind
    kubectl
    kubernetes-helm
    kubeswitch
    kustomize
    opentofu
    terraform-docs
  ];
}
