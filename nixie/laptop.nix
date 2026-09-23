{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  networking.hostName = "nixie";

  # Swapfile for hibernation on BTRFS in LUKS
  swapDevices = [
    {
      device = "/.swapvol/swapfile";
      size = 32 * 1024;
    }
  ];

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

  # For ambient light sensor support in KDE 6.6
  # See https://bugs.kde.org/show_bug.cgi?id=502122#c4
  hardware.sensor.iio.enable = true;

  # GFX11.5 CWSR wedges the MES scheduler; revisit when the kernel ~7.3 fix lands.
  boot.kernelParams = ["amdgpu.cwsr_enable=0"];

  # Image is written either way; S5 poweroff avoids the S4 abort that wedges amdgpu.
  systemd.sleep.settings.Sleep.HibernateMode = "shutdown";
}
