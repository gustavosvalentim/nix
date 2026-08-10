{ ... }: 

{
  homebrew = {
    enable = true;
    taps = [
      "oven-sh/bun"
      "anomalyco/tap"
    ];

    brews = [
      "cowsay"
      "asdf"
      "oven-sh/bun/bun"
      "anomalyco/tap/opencode"
      "kubectl"
      "kustomize"
      "kubectx"
      "k9s"
      "worktrunk"
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
      "codex"
      "beekeeper-studio"
      "rectangle"
    ];

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # Keep manual brews/casks; "zap" removes items not declared here.
      cleanup = "none";
    };

    extraConfig = ''
      ENV["HOMEBREW_NO_REQUIRE_TAP_TRUST"] = "1"
    '';
  };
}
