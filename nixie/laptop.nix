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

  # amdgpu.cwsr_enable=0: GFX11.5 (Radeon 890M) has broken CWSR (Compute Wave Save/Restore) that
  # wedges the MES scheduler so GPU fences never signal. During the hibernate freeze that surfaces
  # as amdgpu_vm_fini/dma_fence_wait_timeout: any GPU-accelerated app "refuses to freeze" and
  # hibernate aborts "Device or resource busy". Disabling CWSR is the documented workaround
  # (ROCm #5590/#5724, Framework AMD AI 300 threads). Proper fix targets kernel ~7.3
  # (amd-drm-next-7.3-2026-07-09: "Fix CWSR buffer mapping when in VRAM"); revisit/re-enable then.
  boot.kernelParams = ["amdgpu.cwsr_enable=0"];
}
