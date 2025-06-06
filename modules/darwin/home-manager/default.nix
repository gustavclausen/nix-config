{
  currentSystemUser,
  host,
  inputs,
  agenix,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    users.${currentSystemUser} = {
      pkgs,
      config,
      lib,
      ...
    }: {
      xdg.enable = true;
      home = {
        packages = import ./packages.nix {inherit pkgs;};
      };
      imports = [
        (import ./dock)
        (import ../../shared/home-manager {inherit pkgs inputs host agenix lib config;})
      ];
      fonts.fontconfig.enable = true;
      programs.zsh.initContent = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
    };
  };
}
