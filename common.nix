# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  
  # Enable flakes and automatically clean up the nix store
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = "nix-command flakes";
  };
  nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
  };

  # Bootloader
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 8;
    consoleMode = "auto";
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Firmware
  services.fwupd.enable = true;
  hardware.enableAllFirmware = true;

  # Enable networking
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  # Set the time zone automatically based on rough location, once, at startup.
  time.timeZone = null;
  services.tzupdate.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    autoLogin.enable = false;
  };

  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
 
  # User Settings
  programs.fish.enable = true;
  users.users.ciferkey = {
    isNormalUser = true;
    description = "ciferkey";
    extraGroups = [ 
      "adbusers"
      "camera" 
      "dialout" # Allow access to serial device
      "docker"
      "lp"
      "networkmanager"
      "scanner"
      "wheel" 
    ];
    packages = with pkgs; [
      git
      home-manager
      neovim
      nh
    ];
    shell = pkgs.fish;
  };
  security.pam.services = {
    ciferkey.enableKwallet = true;
    sddm.kwallet = {
      enable = true; # Fix to allow SDDM to start KWallet properly
      forceRun = true;
    };
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  # ADB has to be enabled this way https://nixos.wiki/wiki/Android
  programs.adb.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kdePackages.ark
    kdePackages.breeze-gtk
    kdePackages.discover
    kdePackages.kamera
    kdePackages.kio-gdrive
    kdePackages.plasma-integration
    kdePackages.plasma-nm
    kdePackages.sddm-kcm
    tailscale-systray
  ];

  services.tailscale.enable = true;

  programs.partition-manager.enable = true;

  services.flatpak.enable = true;
  services.packagekit.enable = true;

  programs.kdeconnect.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";

  # Game Support
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
  };
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.steam-hardware.enable = true;
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  services = {
    udev = {
      packages = with pkgs; [
        # Controller stuff https://codeberg.org/fabiscafe/game-devices-udev#nixos
        game-devices-udev-rules
        yubikey-personalization
      ];
    };
  };
  hardware.uinput.enable = true;

  zramSwap.enable = true;

  
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Virtualization
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
    };
  };

  services.fstrim.enable = true;

  programs.gphoto2.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Enable mdns for .local domains
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
}
