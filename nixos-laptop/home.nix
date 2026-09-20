{ inputs, lib, config, pkgs, ... }:
{
  home = {
    username = "lilith";
    homeDirectory = "/home/lilith";
    stateVersion = "26.05";
  };

  home.persistence."/persist/home" = {
    directories = [
      "Desktop"
      "Downloads"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
      "Projects"
    ];
    files = [
      ".screenrc"
    ];
  };

  home.persistence."/persist/home/dots" = {
    directories = [
      ".config"
      ".kde"
      ".local"
      { directory = ".ssh"; mode = "0700"; }
    ];
  };

  home.sessionVariables = {
    EDITOR = "nano";
    VISUAL = "nano";
    PAGER = "less";
    LESS = "-R";
    MANPAGER = "less -R";
    BROWSER = "zen-beta";
    TERMINAL = "kitty";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/share/pnpm"
  ];

  home.packages = with pkgs; [
    distrobox
    boxbuddy
    bottles

    zip
    unzip
    p7zip

    ffmpeg
    vlc
    obs-studio
    tenacity
    krita
    blender
    davinci-resolve

    uv
    texlive
    typst
    devenv
    direnv
    git
    libreoffice
    vscode
    zotero
    obsidian
    anki
    opencode

    bleachbit
    keepassxc
    qbittorrent-enhanced
    kdePackages.kdeconnect-kde

    opentofu
    ansible
    podman
    podman-compose
    udiskie
    ripgrep
    btop
    curl
    wget
    which
    tree
    file
    pciutils
    usbutils
    cpufrequtils
    smartmontools   
    bat
    eza
    fd
    fzf
    jq
    yq
    tmux
    zoxide
    starship
    gallery-dl
    yt-dlp
    mkcert
    flatpak
  ];

  programs = {
    zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;

      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
        "--cycle"
        "--info=inline"
        "--smart-case"
      ];
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;

      options = [
        "--cmd"
        "cd"
      ];
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      historySubstringSearch.enable = true;

      setOptions = [
        "AUTO_CD"
        "AUTO_PUSHD"
        "PUSHD_IGNORE_DUPS"
        "PUSHD_SILENT"
        "EXTENDED_GLOB"
        "NO_BEEP"
        "INTERACTIVE_COMMENTS"
      ];

      history = {
        size = 100000;
        save = 100000;
        path = "$HOME/.local/share/zsh/history";

        ignoreDups = true;
        ignoreAllDups = true;
        expireDuplicatesFirst = true;
        ignoreSpace = true;
        share = true;
        extended = true;
      };

      plugins = [
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
          file = "fzf-tab.plugin.zsh";
        }
      ];
    };

    nixvim = {
      enable = true;
      colorschemes.gruvbox.enable = true;
      plugins.lualine.enable = true;

      lsp.servers = {
        docker_language_server.enable = true;
        emmylua_ls.enable = true;
        html.enable = true;
        java_language_server.enable = true;
        markdown_oxide.enable = true;
        nginx_language_server.enable = true;
        nixd.enable = true;
        postgres_lsp.enable = true;
        pyright.enable = true;
        rust_analyzer.enable = true;
        terraform_lsp.enable = true;
        texlab.enable = true;
        tinymist.enable = true;
        tofu_ls.enable = true;
      };

      plugins = {
        wezterm.enable = true;
        typst-preview.enable = true;
        telescope.enable = true;
        quarto.enable = true;
        quickmath.enable = true;
        opencode.enable = true;
        nix.enable = true;
        molten.enable = true;
        markdown-preview.enable = true;
        lazygit.enable = true;
        image.enable = true;
        direnv.enable = true;
        dashboard.enable = true;
      };
    };

    kitty = {
      enable = true;
      settings = {
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";

        cursor_trail = 10;
        cursor_trail_start_threshold = 0;
        cursor_trail_decay = "0.01 0.05";
        cursor_blink = true;

        background_opacity = 0.5;
        background_blur = 32;
      };
    };
  };
}
