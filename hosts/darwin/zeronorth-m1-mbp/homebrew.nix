{inputs}: {
  extraCasks = ["another-redis-desktop-manager" "aws-vpn-client" "inkscape" "google-drive" "linear-linear" "notion" "pritunl"];
  extraTaps = {
    "argoproj/homebrew-tap" = inputs.homebrew-argoproj;
  };
  extraBrews = ["kubectl-argo-rollouts"];
}
