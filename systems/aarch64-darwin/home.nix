{ pkgs, lib, username, config, ... }:

{
  # this is internal compatibility configuration
  # for home-manager, don't change this!
  home.stateVersion = "23.05";

  # Disabled for now since we mismatch our versions. See flake.nix for details.
  home.enableNixpkgsReleaseCheck = false;

  xdg.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    PATH   = "$\{ASDF_DATA_DIR:-$HOME/.asdf\}/shims:$PATH";
    OPENCODE_CONFIG = "$HOME/.config/opencode/opencode.jsonc";
  };

  home.packages = let
    packages = import ../../common/packages.nix { inherit pkgs username config; };
    in packages.darwinPackages;

  fonts.fontconfig.enable = true;

  home.activation.cloneNeovimConfig = lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" "programs.git" ] ''
    echo "Running post-rebuild script" >> /tmp/nix-darwin-activation.log
    REPOSITORY="https://github.com/gustavosvalentim/nvim"
    DIRECTORY="$HOME/.config/nvim"
    if [ ! -d "$DIRECTORY" ]; then
      ${pkgs.git}/bin/git clone "$REPOSITORY" "$DIRECTORY"
    fi
  '';

  # Codex does not reliably discover user skills when SKILL.md/openai.yaml are symlinks.
  # Keep source of truth in nix and copy concrete files into ~/.codex/skills at activation.
  home.activation.syncCodexSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CODEX_SKILLS_DIR="$HOME/.codex/skills"
    mkdir -p "$CODEX_SKILLS_DIR"

    rm -rf "$CODEX_SKILLS_DIR/commit" "$CODEX_SKILLS_DIR/planning" "$CODEX_SKILLS_DIR/pre-commit"

    cp -R ${../../common/codex/skills/commit} "$CODEX_SKILLS_DIR/commit"
    cp -R ${../../common/codex/skills/planning} "$CODEX_SKILLS_DIR/planning"
    cp -R ${../../common/codex/skills/pre-commit} "$CODEX_SKILLS_DIR/pre-commit"
  '';

  home.file."ghostty-config" = {
    target = "Library/Application Support/com.mitchellh.ghostty/config";
    source = ../../common/ghostty/config;
    force = true;
  };

  # Workaround for muting ghostty when resizing split windows
  # https://github.com/ghostty-org/ghostty/discussions/5521#discussioncomment-12306028
  home.file."macos-default-keybinding" = {
    target = "/Users/${username}/Library/KeyBindings/DefaultKeyBinding.dict";
    source = ../../common/macos/DefaultKeyBinding.dict;
  };

  home.file."opencode-agent-md" = {
    target = "/Users/${username}/.config/opencode/AGENTS.md";
    source = ../../common/opencode/AGENTS.md;
  };

  home.file."opencode-config" = {
    target = "/Users/${username}/.config/opencode/opencode.jsonc";
    source = ../../common/opencode/opencode.jsonc;
  };

  home.file."opencode-skill-skill-creator" = {
    target = "/Users/${username}/.config/opencode/skills/skill-creator";
    source = ../../common/opencode/skills/skill-creator;
    recursive = true;
  };

  home.file."opencode-skill-commit" = {
    target = "/Users/${username}/.config/opencode/skills/commit";
    source = ../../common/codex/skills/commit;
    recursive = true;
  };

  home.file."opencode-skill-planning" = {
    target = "/Users/${username}/.config/opencode/skills/planning";
    source = ../../common/codex/skills/planning;
    recursive = true;
  };

  home.file."opencode-skill-pre-commit" = {
    target = "/Users/${username}/.config/opencode/skills/pre-commit";
    source = ../../common/codex/skills/pre-commit;
    recursive = true;
  };

  home.file."codex-config" = {
    target = "/Users/${username}/.codex/config.toml";
    source = ../../common/codex/config.toml;
    force = true;
  };

  programs =
    let packages = import ../../common/packages.nix { inherit pkgs username config; };
    in packages.programs;
}
