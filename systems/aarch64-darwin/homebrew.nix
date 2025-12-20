{ ... }: 

{
  homebrew = {
    enable = true;
    taps = [ ];

    brews = [
      "cowsay"
      "asdf"
    ];

    casks = [
      "ghostty"
      "orbstack"
      "keeper-password-manager"
      "zen"
      "spotify"
      "vlc"
      "obsidian"
      "opencode"
    ];

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
  };
}
