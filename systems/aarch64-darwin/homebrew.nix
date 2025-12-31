{ ... }: 

{
  homebrew = {
    enable = true;
    taps = [ ];

    brews = [
      "cowsay"
      "asdf"
      "opencode"
      "keeper-commander"
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
