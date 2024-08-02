#u This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    config = {
      allowUnfree = true;
    };
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;
  
  # Enable flakes and automatically clean up the nix store
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = "nix-command flakes";
    substituters = [ "https://devenv.cachix.org" ];
    trusted-public-keys = [ "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" ];
  };
  nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
  };

  # Bootloader
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 8;
    consoleMode = "auto";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ntfs" ];

  # Firmware
  services.fwupd.enable = true;
  hardware.enableAllFirmware = true;

  # Enable networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  # Set your time zone.
  time.timeZone = "America/New_York";

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
    sddm.enable = true;
    autoLogin.enable = true;
    autoLogin.user = "ciferkey";
  };

  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
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
    extraGroups = [ "adbusers" "docker" "networkmanager" "wheel" ];
    packages = with pkgs; [
      git
      neovim
    ];
    shell = pkgs.fish;
  };
  security.pam.services.ciferkey.enableKwallet = true;

  # ADB has to be enabled this way https://nixos.wiki/wiki/Android
  programs.adb.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kdePackages.ark
    kdePackages.breeze-gtk
    kdePackages.discover
    kdePackages.kio-gdrive
    kdePackages.plasma-integration
    kdePackages.plasma-nm
    kdePackages.sddm-kcm
    #kdePackages.polonium
    #razergenie
    tailscale
    tailscale-systray
  ];

  #services.tailscale.enable = true;

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
    gamescopeSession.enable = true;
  };
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.steam-hardware.enable = true;
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  #hardware.openrazer.enable = true;
  #hardware.openrazer.users = [ "ciferkey" ];
  programs.corectrl.enable = true;

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

  services = {
    syncthing = {
        enable = true;
        user = "ciferkey";
    };
  };

  # Fix EDID for monitor on AMD
  hardware.display.edid.linuxhw."XL2420G_2014" = ["XL2420G" "2014"];
  hardware.display.outputs."DP-2".edid = "XL2420G_2014.bin";
  hardware.display.outputs."DP-2".mode = "e";
}
