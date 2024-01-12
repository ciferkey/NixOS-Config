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
      (final: prev: {
        r2modman = prev.r2modman.overrideAttrs (old: {
          src = prev.fetchFromGitHub {
            owner = "ebkr";
            repo = "r2modmanplus";
            rev = "v3.1.45";
            hash = "sha256-6o6iPDKKqCzt7H0a64HGTvEvwO6hjRh1Drl8o4x+4ew=";
          };
        });
      })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
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
  };
  nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
  };

  # Bootloader
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
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
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
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
    extraGroups = [ "adbusers" "networkmanager" "wheel" ];
    packages = with pkgs; [
      git
      neovim
    ];
    shell = pkgs.fish;
  };

  # ADB has to be enabled this way https://nixos.wiki/wiki/Android
  programs.adb.enable = true;

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "ciferkey";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    libsForQt5.ark
    libsForQt5.breeze-gtk
    libsForQt5.discover
    libsForQt5.kio-gdrive
    libsForQt5.plasma-integration
    libsForQt5.plasma-nm
    unstable.libsForQt5.polonium
    #tailscale-systray
  ];

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
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [ "ciferkey" ];
  programs.corectrl.enable = true;

  zramSwap.enable = true;

  
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

}
