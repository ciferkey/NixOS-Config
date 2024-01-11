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

  home.packages = with pkgs; [
    autojump
    btop
    fd
    fzf
    nixpkgs-review
    nix-update
    reptyr
    unzip
  ];

  home = {
    username = "ciferkey";
    homeDirectory = "/home/ciferkey";
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "zenburn";
    };
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
     rebuild = "sudo nixos-rebuild switch --show-trace";
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

  # Enable home-manager
  programs.home-manager.enable = true;
  
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

  programs.nix-index.enable = true;
  
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
}
