{ ... }: 

{
  homebrew = {
    enable = true;
    taps = [ ];

    brews = [
      "cowsay"
      "asdf"
      "oven-sh/bun/bun"
      "opencode"
      "kubectl"
      "kustomize"
      "kubectx"
      "k9s"
      "gh"
      "codex"
    ];

    casks = [
      "ghostty"
      "orbstack"
      "zen"
      "spotify"
      "vlc"
      "obsidian"
      "clipy"
      "1password"
      "1password-cli"
    ];

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # Keep manual brews/casks; "zap" removes items not declared here.
      cleanup = "none";
    };
  };
}
