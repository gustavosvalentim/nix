{ ... }: 

{
  homebrew = {
    enable = true;
    taps = [
      "anomalyco/tap"
      "fluxcd/tap"
      "hashicorp/tap"
      "oven-sh/bun"

      {
        name = "jundot/omlx";
        clone_target = "git@github.com:jundot/omlx.git";
        force_auto_update = true;
      }
    ];

    brews = [
      "age"
      "asdf"
      "awscli"
      "cowsay"
      "fluxcd/tap/flux"
      "jundot/omlx/omlx"
      "k9s"
      "kubectl"
      "kubectx"
      "kustomize"
      "oven-sh/bun/bun"
      "pi-coding-agent"
      "sops"
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
