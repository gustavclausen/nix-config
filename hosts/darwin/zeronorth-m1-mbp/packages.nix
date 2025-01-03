{pkgs}: {
  extraUserPackages = with pkgs; [
    argocd
    aws-nuke
    cloud-custodian
    copier
    eks-node-viewer
    eksctl
    helm-docs
    helmfile
    istioctl
    k6
    k9s
    kind
    kubectl
    kubernetes-helm
    kubeswitch
    kustomize
    kyverno
    ngrok
    poetry
    postgresql
    pyenv
    redis
    slack
    terraform
    terraform-docs
    tflint
  ];
}
