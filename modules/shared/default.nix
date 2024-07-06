{...}: {
  imports = [
    ./nvim
    ./git-user
    ./zn-scripts
    ./colima
  ];

  local.nvim.enable = true;
  local.colima.enable = true;
}
