#!/usr/bin/env bash

[[ -f dotfiles.conf ]] && source dotfiles.conf

source dotfiles.lib.sh

# Prepare setup
prepare

# Link *.rc to dotfiles
install_rcfiles

