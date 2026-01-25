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
      "keeper-commander"
      "kubernetes-cli"
      "kubectx"
      "k9s"
    ];

    casks = [
      "ghostty"
      "orbstack"
      "keeper-password-manager"
      "zen"
      "spotify"
      "vlc"
      "obsidian"
      "clipy"
    ];

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
  };
}
