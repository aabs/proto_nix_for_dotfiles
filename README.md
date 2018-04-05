# Nix for dotfiles

This repo contains a little test to replicate part of the operation of nix for use in dotfiles (uses fish shell).

Features:

- Safely preserves pre-existing dotfiles
- Only intercepts and manages dotfiles when a new managed replacement exists
- Generational model of resources, similar to nix approach
- Roll back and roll forward through successive generations
- Allows implementation in folders other than `$HOME`
- Scans deployment source directory for symlinks to attach, safely preserving any matching originals

The functionality prototyped here will be implemented in [fishdots](http://github.com/aabs/fishdots), but you can adapt it for you own uses too.  To use it, you have two ways to use it. The first is incremental and fine grained:

```fish
set -l new_gen (create_new_gen)
stage_link_to_file_in_index "$PWD/dotsv1/script.v1.sh" "script.sh" $new_gen
stage_link_to_file_in_index "$PWD/dotsv1/script2.v1.sh" "script2.sh" $new_gen
switch_default_to_new_generation $new_gen
```

`create_new_gen` creates a new generation directory under `$GEN_ROOT` (something that can be overridden to target something other than `$HOME/gens'` if need be.
`stage_link_to_file_in_index` establishes a link in the new index. `script.v1.sh` will be indirectly linked to `script.sh` in the new generation directory.  All staged links are pending till you call `switch_default_to_new_generation` which redirects `default` to point to the new generation folder.  

The second way to stage files as part of a new generation is to scan for symlink files:

```fish
set -l new_gen (create_new_gen)
stage_matching_files_as_dotfiles "$PWD/dotsv1" $new_gen "$PWD/home"
switch_default_to_new_generation $new_gen
```

This is simpler, but only works for literal dot files (e.g. like `.bashrc` or `.vimrc`).  It works by scanning some source directory for any files or folders ending with the suffix `.symlink`. These files are stripped of the suffix, and get a dot appended to their basename. For instance `mysource/directory/bashrc.symlink` becomes `generation-x/.bashrc`.  This is great if you havea traditional dotfiles system where you want to provide new instances of all matching symlinks, but you don't want to clobber any other dotfiles or symlinks in your home folder.

## Making dotfiles indirect

As with Nix, the final call to `switch_default_to_new_generation` is atomic, because it works through a call to `ln -s` on linux, so this little prototype could be considered atomic, except for one caveat.  The process of intercepting a dotfile and redirecting it is pre-emptively done when the call to `stage_link_to_file_in_index` is made, so there are side effects in advance of the call to `switch_default_to_new_generation`.  That is, anything you **stage for inclusion** as a link in a generation gets moved to a special generation called `$HOME/gens/origin`, the original is replaced with a symbolic link to the new location of the original.  In terms of end-user experience, the process is transparent, but it is still a side effect.

Rollbacks from the first generation of changes will cause `gens/default` to point to `gens/origin`, thereby reestablishing links from home to the original file that was there prior to the first update.
