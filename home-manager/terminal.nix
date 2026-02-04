{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.atuin.enable = true;

  programs.bat = {
    enable = true;
    config = {
      theme = "zenburn";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      line-numbers = true;
      side-by-side = true;
      syntax-theme = "zenburn";
    };
  };

  programs.eza = {
    enable = true;
    git = true;
  };

  programs.fish = {
    enable = true;
    plugins = [
      { 
        name = "fzf-fish"; 
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      { 
        name = "tide"; 
        src = pkgs.fishPlugins.tide.src;
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
     rebuild = "nh os switch .";
     reflake = "nix flake update";
     rehome = "nh home switch .";
     repair = "sudo nix-store --repair --verify --check-contents";
     ks = "kitten ssh";
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings.git_protocol = "ssh";
  };

  programs.gh-dash.enable = true;

  programs.git = {
    enable = true;
    settings = {
      alias = {
        cam = "commit -am";
        ch = "checkout HEAD --";
        d = "-p diff";
        lom = "pull origin master";
        pom = "push origin master";
        rh = "reset --hard HEAD";
        s = "status";
      };
      user = {
        name  = "ciferkey";
        email = "ciferkey@gmail.com";
      };
      extraConfig = {
        pull.rebase = true;
      };
    };
  };

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      font-family = "Inconsolata LGC Nerd Font Mono";
      theme = "Zenburn";
      keybind = [
        # https://ghostty.org/docs/config/keybind/reference#toggle_quick_terminal
        "global:super+a=toggle_quick_terminal"
      ];
      quick-terminal-size = "50%";
    };
  };

  programs.navi = {
    enable = true;
  };

  programs.neovim = {
    defaultEditor = true;
    enable = true;
    extraConfig = ''
      colorscheme zenburn
      set mouse=a
      set nu
    '';
    extraPackages = [
      pkgs.ripgrep
      pkgs.wl-clipboard
    ];
    plugins = [
      pkgs.vimPlugins.vim-nix
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      pkgs.vimPlugins.zenburn
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
      tmuxPlugins.better-mouse-mode
      #tmuxPlugins.resurrect
      #tmuxPlugins.continuum
    ];
    terminal = "tmux-256color";
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
