# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
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
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    anki
    bottles
    btop
    cachix
    caffeine-ng
    dbeaver
    docker-compose
    discord
    efibootmgr
    freetube
    fd
    fzf
    insomnia
    jellyfin-media-player
    jetbrains.pycharm-professional
    lutris
    mangohud
    (nerdfonts.override { fonts = [ "Hack" "InconsolataLGC" ]; })
    nixpkgs-review
    nix-update
    obsidian
    picard
    pocket-casts
    unstable.r2modman
    unzip
    xivlauncher
  ];

  home = {
    username = "ciferkey";
    homeDirectory = "/home/ciferkey";
  };

  programs.autojump.enable = true;

  programs.bat = {
    enable = true;
    config = {
      theme = "zenburn";
    };
  };

  programs.chromium = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fish = {
    enable = true;
    plugins = [
      { 
        name = "fzf-fish"; 
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "tmux";
        src = pkgs.fetchFromGitHub {
          owner = "budimanjojo";
          repo = "tmux.fish";
          rev = "e5874377b3d1359877053df7a9ea8aaeaf3bed2b";
          sha256 = "sha256-+Z49BvoEdnvkuGibsHd5KjLQNUj+qJKHgq4Zey26s4k=";
        };
      }
    ];
    shellAliases = {
     g = "git";
     rebuild = "sudo nixos-rebuild switch --flake .#nixos";
     rehome = "home-manager switch --flake .#ciferkey@nixos";
     rwin = "sudo efibootmgr -n 0 && sudo reboot now";
    };
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "media.ffmpeg.vaapi.enabled" = "true";
      };
    };
    package = pkgs.firefox.override {
      cfg = {
        nativeMessagingHosts = [ 
          pkgs.plasma5Packages.plasma-browser-integration
          pkgs.tridactyl-native
        ]; 
        speechSynthesisSupport = true;
      };
    };
  };

  programs.git = {
    enable = true;
    aliases = {
      cam = "commit -am";
      ch = "checkout HEAD --";
      d = "-p diff";
      lom = "pull origin master";
      pom = "push origin master";
      rh = "reset --hard HEAD";
      s = "status";
    };
    delta.enable = true;
    delta.options = {
      line-numbers = true;
      side-by-side = true;
      syntax-theme = "zenburn";
    };
    userName  = "ciferkey";
    userEmail = "ciferkey@gmail.com";
    extraConfig = {
      pull.rebase = true;
    };
  };

  programs.home-manager.enable = true;

  programs.kitty = {
    enable = true;
    font.name = "InconsolataLGC Nerd Font Mono";
    theme = "Zenburn";
    settings = {
      adjust_line_height = 1; # Needed to fix nerd fonts
      wayland_titlebar_color = "background";
    };
  };

  programs.navi = {
    enable = true;
  };
  
  programs.neovim = {
    defaultEditor = true;
    enable = true;
    extraConfig = ''
      set mouse=a
      set nu
    '';
    plugins = [
      pkgs.vimPlugins.vim-nix
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];
    vimAlias = true;
  };

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };
  
  programs.tmux = {
    enable = true;
    mouse = true;
    plugins = with pkgs; [
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
    ];
    terminal = "tmux-256color";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0" # until obsidian gets their act together
  ];

  services.udiskie.enable = true; # Auto mount usb drives

}
