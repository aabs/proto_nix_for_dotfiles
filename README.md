# Nix for dotfiles

This repo contains a little test to replicate part of the operation of nix for use in dotfiles (uses fish shell).

Features:

- Safely preserves pre-existing dotfiles
- Only intercepts and manages dotfiles when a new managed replacement exists
- Generational model of resources, similar to nix approach
- Roll back and roll forward through successive generations
- Allows implementation in folders other than `$HOME`
- Scans deployment source directory for symlinks to attach, safely preserving any matching originals
