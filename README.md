# Dotfiles
This directory contains all of config files for replicating current system, managed by gnu stow.

## Requirements
1. stow
   ``` sh
   sudo pacman -S stow
   ```
   above command would install stow. this utility create symbolic link between files that it's manage and home directory.

## Usage
``` sh
stow .
```
inside directory that you want to manage you dotfiles.
