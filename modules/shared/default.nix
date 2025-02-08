{...}: {
  imports = [
    ./nvim
    ./git-user
    ./secrets.nix
  ];

  local.nvim.enable = true;
}
