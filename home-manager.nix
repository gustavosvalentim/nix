{ pkgs, lib, ... }:

{

  # this is internal compatibility configuration 
  # for home-manager, don't change this!
  home.stateVersion = "23.05";
  # Let home-manager install and manage itself.
  programs.home-manager.enable = true;

  # Disabled for now since we mismatch our versions. See flake.nix for details.
  home.enableNixpkgsReleaseCheck = false;

  xdg.enable = true;

  programs = {
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
        switch = "sudo darwin-rebuild switch --flake $HOME/.config/nix";
        nix-clear = "nix-collect-garbage -d";
        nix-config = "$EDITOR $HOME/.config/nix";
        vim-config = "$EDITOR $HOME/.config/nvim";
        la = "ls -AF";
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

  home.sessionVariables = {
    EDITOR = "nvim";
    PATH   = "$\{ASDF_DATA_DIR:-$HOME/.asdf\}/shims:$PATH";
  };

  home.packages = with pkgs; [
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

  home.activation.cloneNeovimConfig = lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" "programs.git" ] ''
    echo "Running post-rebuild script" >> /tmp/nix-darwin-activation.log
    REPOSITORY="https://github.com/gustavosvalentim/nvim"
    DIRECTORY="$HOME/.config/nvim"
    if [ ! -d "$DIRECTORY" ]; then
      ${pkgs.git}/bin/git clone "$REPOSITORY" "$DIRECTORY" 
    fi
  '';
}
