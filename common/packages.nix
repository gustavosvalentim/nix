{pkgs, ... }: 

{
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

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        dark = true;
        lineNumbers = true;
        side-by-side = true;
        features = "unobtrusive-line-numbers decorations";
        interactive = {
          diffFilter = "delta --color-only";
        };
        merge = {
          conflitStyle = "zdiff3";
        };
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow ul";
          file-decoration-style = "none";
          hunk-header-decoration-style = "yellow box";
        };
        unobstrusive-line-numbers = {
          line-numbers = "true";
          line-numbers-minus-style = "#444444";
          line-numbers-zero-style = "#444444";
          line-numbers-plus-style = "#444444";
          line-numbers-left-format = "{nm:>4}┊";
          line-numbers-right-format = "{np:>4}│";
          line-numbers-left-style = "blue";
          line-numbers-right-style = "blue";
        };
      };
    };

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
        GOPATH = "Documents/go";
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

    opencode = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        autoupdate = true;
        mcp = {
          sequential-thinking = {
            enabled = true;
            type = "local";
            command = ["npx" "-y" "@modelcontextprotocol/server-sequential-thinking"];
          };

          mcp-docs = {
            enabled = true;
            type = "local";
            command = ["npx" "-y" "mcp-remote" "https://gitmcp.io/docs"];
          };
        };
      };
    };
  };
}
