# Dotfiles
This directory contains all of config files for replicating current system, managed by gnu stow.

## Requirements
1. stow
   ``` sh
   sudo pacman -S stow
   ```
   above command would install stow. this utility create symbolic link between files that it's manage and home directory.

2. zsh
   ``` sh
   sudo pacman -S zsh
   ```

## Usage

First, clone this repo.
``` sh
git clone git@github.com:mohammadekhosravi/dotfiles.git
cd dotfiles
```

then use stow to create symlinks

``` sh
stow .
```

Make zsh primary shell
``` sh
chsh $(whoami)
```
