{ pkgs, lib, inputs, username, config, ... }:

{
  imports = [
    inputs.hunk.homeManagerModules.default
  ];

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
    in packages.darwinPackages ++ [
      inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

  programs =
    let packages = import ../../common/packages.nix { inherit pkgs username config; };
    in packages.programs;

  fonts.fontconfig.enable = true;

  home.activation.cloneNeovimConfig = lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" "programs.git" ] ''
    echo "Running post-rebuild script" >> /tmp/nix-darwin-activation.log
    REPOSITORY="https://github.com/gustavosvalentim/nvim"
    DIRECTORY="$HOME/.config/nvim"
    if [ ! -d "$DIRECTORY" ]; then
      ${pkgs.git}/bin/git clone "$REPOSITORY" "$DIRECTORY"
    fi
  '';

  # Copy Codex config/prompts to avoid symlinks.
  home.activation.syncCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CODEX_DIR="$HOME/.codex"
    mkdir -p "$CODEX_DIR"

    rm -f "$CODEX_DIR/config.toml"
    cp ${../../common/codex/config.toml} "$CODEX_DIR/config.toml"
  '';

  # Pi mutates settings.json, so deploy managed configuration by copying rather
  # than symlinking it from the Nix store. Credentials, sessions, packages, and
  # other runtime state in ~/.pi remain unmanaged.
  home.activation.syncPiConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    PI_DIR="$HOME/.pi/agent"
    mkdir -p "$PI_DIR/extensions/load-env" \
      "$PI_DIR/skills/gitting-gud" \
      "$PI_DIR/skills/stupid"

    cp ${../../common/pi/settings.json} "$PI_DIR/settings.json"
    cp ${../../common/pi/extensions/custom-statusline.ts} "$PI_DIR/extensions/custom-statusline.ts"
    cp ${../../common/pi/extensions/tsconfig.json} "$PI_DIR/extensions/tsconfig.json"
    cp ${../../common/pi/extensions/load-env/index.ts} "$PI_DIR/extensions/load-env/index.ts"
    cp ${../../common/pi/extensions/load-env/package.json} "$PI_DIR/extensions/load-env/package.json"
    cp ${../../common/pi/extensions/load-env/README.md} "$PI_DIR/extensions/load-env/README.md"
    cp ${../../common/pi/skills/gitting-gud/SKILL.md} "$PI_DIR/skills/gitting-gud/SKILL.md"
    cp ${../../common/pi/skills/stupid/SKILL.md} "$PI_DIR/skills/stupid/SKILL.md"
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

  home.file."opencode-config" = {
    target = "/Users/${username}/.config/opencode/opencode.jsonc";
    source = ../../common/opencode/opencode.jsonc;
  };

  home.file."herdr-config" = {
    target = "/Users/${username}/.config/herdr/config.toml";
    source = ../../common/herdr/config.toml;
    force = true;
  };

  # home.activation.worktrunkConfigure = lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" ] ''
  #   /opt/homebrew/bin/wt config shell install
  # '';

}
