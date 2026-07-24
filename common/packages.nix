{ pkgs, username, config, ... }: 

{
  darwinPackages = with pkgs; [
    bat
    ripgrep
    tree
    golangci-lint
    gopls
    nodejs
    claude-code
    jq
    uv
    zoxide

    jetbrains-mono

    nerd-fonts.fira-code
    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono

  ];

  programs = {
    # Let home-manager install and manage itself.
    home-manager.enable = true;

    hunk = {
      enable = true;
      enableGitIntegration = true;
      settings = {
        theme = "github-dark-default";
        mode = "split";
        line_numbers = true;
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    jq = {
      enable = true;
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
        nixswitch = "sudo darwin-rebuild switch --flake $HOME/.config/nix --print-build-logs --show-trace -vvv";
        nixclear = "nix-collect-garbage -d";
        nixconfig = "$EDITOR $HOME/.config/nix";
        vimconfig = "$EDITOR $HOME/.config/nvim";
        opencode = "command opencode --port";
        la = "ls -laF";
        gs = "git status";
        gc = "git commit";
        gp = "git push";
        gl = "git log";
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
          pull.rebase = true;
        };
      };
      ignores = [ ".DS_Store" ];
    };

    go = {
      enable = true;
      env = { 
        GOPATH = "${config.home.homeDirectory}/go";
        GOBIN = "${config.home.homeDirectory}/go/bin";
        GOPRIVATE = [ "github.com/gustavosvalentim" ];
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
