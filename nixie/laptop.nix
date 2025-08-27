{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {

  # For hibernate to work with swapfile on BRTFS in LUKS
  boot.initrd.systemd.enable = true;
  swapDevices = [{
    device = "/.swapvol/swapfile";
    size = 32 * 1024;
  }];


  # Secure boot
  # https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md#configuring-nixos-with-flakes
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

}
