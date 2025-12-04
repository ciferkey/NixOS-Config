{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {

  networking.hostName = "nixie";

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

  # Replace power-profile-daemon with tuned. Fedora uses it by default now
  # https://fedoraproject.org/wiki/Changes/TunedAsTheDefaultPowerProfileManagementDaemon
  services.tlp.enable = false; # the nixos-hardware module will turn this on, when Framework recommends _not_ using tlp.
  #services.power-profiles-daemon.enable = true;
  services.tuned = {
    enable = true;
    settings.dynamic_tuning = true;
    #ppdSettings.main.default = "powersave";
  };

}
