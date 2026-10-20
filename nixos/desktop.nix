{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  networking.hostName = "nixos";

  # Fix EDID for monitor on AMD
  hardware.display.edid.linuxhw."XL2420G_2014" = [
    "BNQ7F39"
    "XL2420G"
    "2014"
    "2E7C0DC569A3"
  ];
  hardware.display.outputs."DP-2".edid = "XL2420G_2014.bin";
  hardware.display.outputs."DP-2".mode = "e";

  # Bazzite is on a separate disk with its own ESP. systemd-boot can only chainload it via the EDK2 shell.
  # HD2b is the shell's handle for nvme2n1p1. If drives change, re-find it with `map -c` in the shell.
  boot.loader.systemd-boot = {
    extraFiles."efi/edk2-uefi-shell/shell.efi" = "${pkgs.edk2-uefi-shell}/shell.efi";
    extraEntries."bazzite.conf" = ''
      title Bazzite
      efi /efi/edk2-uefi-shell/shell.efi
      options -nointerrupt -nomap -noversion HD2b:EFI\fedora\shimx64.efi
      sort-key o_bazzite
    '';
  };

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # Steam Frame wireless adapter needs 6 GHz, which the world regdom (00) disables.
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=US
  '';
}
