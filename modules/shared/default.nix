{...}: {
  imports = [
    ./nvim
    ./git-user
    ./zn-scripts
    ./secrets.nix
  ];

  local.nvim.enable = true;
}
