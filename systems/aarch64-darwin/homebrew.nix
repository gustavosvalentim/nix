{ ... }: 

{
  homebrew = {
    enable = true;
    taps = [
      "anomalyco/tap"
      "hashicorp/tap"
      "oven-sh/bun"

      {
        name = "jundot/omlx";
        clone_target = "git@github.com:jundot/omlx.git";
        force_auto_update = true;
      }
    ];

    brews = [
      "asdf"
      "cowsay"
      "jundot/omlx/omlx"
      "k9s"
      "kubectl"
      "kubectx"
      "kustomize"
      "oven-sh/bun/bun"
      "pi-coding-agent"
      "worktrunk"
    ];

    casks = [
      "1password"
      "1password-cli"
      "beekeeper-studio"
      "clipy"
      "codex"
      "hashicorp/tap/hashicorp-vagrant"
      "ghostty"
      "obsidian"
      "orbstack"
      "rectangle"
      "spotify"
      "vlc"
      "zen"
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
