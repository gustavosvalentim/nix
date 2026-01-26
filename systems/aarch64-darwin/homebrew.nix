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
      "kubernetes-cli"
      "kubectx"
      "k9s"
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
      cleanup = "zap";
    };
  };
}
