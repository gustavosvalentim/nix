{pkgs, ... }: {
  darwinPackages = with pkgs; [
    bat
    ripgrep
    tree
    gopls
    nodejs
    claude-code
    jq
    uv
    zoxide
  ];

  programs = {
    # Let home-manager install and manage itself.
    home-manager.enable = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
          "uv"
          "virtualenv"
          "pip"
          "npm"
          "node"
          "macos"
        ];
        theme = "kphoen";
      };
      shellAliases = {
        tree = "tree --gitignore";
        nixswitch = "sudo darwin-rebuild switch --flake $HOME/.config/nix";
        nixclear = "nix-collect-garbage -d";
        nixconfig = "$EDITOR $HOME/.config/nix";
        vimconfig = "$EDITOR $HOME/.config/nvim";
        la = "ls -laF";
        gs = "git status";
        gc = "git commit";
        gp = "git push";
        gl = "git log";
        gd = "git diff $(git rev-parse --abbrev-ref HEAD)";
      };
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "Gustavo Valentim";
          email = "gustavosvalentim1@gmail.com";
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
        };
      };
      ignores = [ ".DS_Store" ];
    };

    go = {
      enable = true;
      env = { 
        GOPATH = "Documents/go";
        GOPRIVATE = [ "github.com/mitchellh" ];
      };
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };
  };
}
