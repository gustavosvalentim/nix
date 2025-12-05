# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a nix-darwin configuration repository for macOS system management using Nix flakes. It combines nix-darwin for system-level configuration with home-manager for user-level dotfile and package management.

## Architecture

### Flake Structure (flake.nix:14-81)

The repository uses a flake-based configuration with three main inputs:
- **nixpkgs**: Base package repository (nixpkgs-25.05-darwin branch)
- **nix-darwin**: macOS system configuration framework (nix-darwin-25.05)
- **home-manager**: User environment and dotfile manager (follows nixpkgs)

The configuration is split into two modules:
1. **System configuration** (inline in flake.nix:16-62): Defines system packages, Homebrew packages/casks, and system settings
2. **Home-manager configuration** (home-manager.nix): Defines user packages, programs, and dotfiles

### Configuration Targets

- **Darwin Configuration Name**: `MacBook-Pro` (flake.nix:68)
- **Primary User**: `gsv` (UID 502) (flake.nix:55-61)
- **Platform**: `aarch64-darwin` (Apple Silicon) (flake.nix:51)

### Key Settings

- Touch ID for sudo is enabled (flake.nix:38)
- Unfree packages are allowed (flake.nix:53)
- Experimental features (nix-command, flakes) are enabled (flake.nix:36)
- Home-manager creates `.bak` backups when overwriting files (flake.nix:76)

## Common Commands

### Apply Configuration Changes
```bash
# From the repository directory or using the shell alias
sudo darwin-rebuild switch --flake ~/.config/nix

# Or use the shell alias defined in home-manager.nix:34
switch
```

### Build Configuration (without applying)
```bash
darwin-rebuild build --flake ~/.config/nix#MacBook-Pro
```

### Update Flake Inputs
```bash
nix flake update
```

### View Changelog
```bash
darwin-rebuild changelog
```

### Search for Packages
```bash
nix-env -qaP | grep <package-name>
```

## Configuration Details

### Package Management Strategy

**System packages** (flake.nix:19): Currently empty - all packages are managed via Homebrew or home-manager

**Homebrew** (flake.nix:21-33): Used for:
- Brews: asdf, cowsay
- Casks: orbstack, keeper-password-manager, zen

**User packages** (home-manager.nix:80-89): Managed by home-manager includes bat, ripgrep, tree, gopls, nodejs, claude-code, jq, uv

### Shell Configuration

Zsh is configured via home-manager with:
- Oh-My-Zsh with "git" and "sudo" plugins
- robbyrussell theme
- Custom aliases: `switch` (for darwin-rebuild) and `tree` (with --gitignore flag)
- fzf with Zsh integration

### Development Environment

**Go** (home-manager.nix:52-58):
- GOPATH: `~/Documents/go`
- GOPRIVATE: `github.com/mitchellh`

**Git** (home-manager.nix:39-50):
- Default branch: main
- Auto setup remote on push
- Ignores .DS_Store files

**Editor**: Neovim (set as default editor, aliased to vim) (home-manager.nix:68-72)

### Activation Scripts

The configuration includes a home-manager activation script (home-manager.nix:91-98) that automatically clones the neovim configuration from https://github.com/gustavosvalentim/nvim to `~/.config/nvim` if it doesn't exist.

## Modifying the Configuration

When adding new packages:
- For GUI applications on macOS, add to `homebrew.casks`
- For CLI tools, add to `home.packages` in home-manager.nix
- For system-wide packages, add to `environment.systemPackages` (though this is currently unused)

When modifying program configurations, edit the appropriate section in `programs` within home-manager.nix.

After any changes, run `switch` or `sudo darwin-rebuild switch --flake ~/.config/nix` to apply.
