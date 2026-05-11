# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # Workaround for https://github.com/NixOS/nixpkgs/issues/514113
    # Remove once https://github.com/NixOS/nixpkgs/pull/515956 lands
    openldap = prev.openldap.overrideAttrs (old: {
      preCheck = (old.preCheck or "") + "\nrm -f tests/scripts/test*-sync*";
    });
  };
}
