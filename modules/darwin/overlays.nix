{...}: {
  nixpkgs.overlays = [
    (final: prev: {
      inetutils = prev.inetutils.overrideAttrs (
        old:
        prev.lib.optionalAttrs prev.stdenv.isDarwin {
          env = (old.env or {}) // {
            NIX_CFLAGS_COMPILE = toString [
              (old.env.NIX_CFLAGS_COMPILE or "")
              "-Wno-format-security"
            ];
          };
        }
      );
    })
  ];
}
