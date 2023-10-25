#!/usr/bin/env bash

######### DOTFILE FUNCTIONS ########

# Check if dotfiles are installed; if not, install and if yes, update.
check_repo() {
# Check if dotfile repository exists
    if [[ ! -d DOTFILES_DIR ]]; then
        git clone "$DOTFILES_REPO_ADDRESS"
    fi
}

# Ensure environment variables exist.
check_variables() {
    [[ -z $DOTFILES_DIR ]] && DOTFILES_DIR="$HOME/.dotfiles";
    [[ -n $DOTFILES_DIR ]] && DOTFILES_DIR="${DOTFILES_DIR%/}";
    [[ ! -d $DOTFILES_DIR ]] && (
        [[ -z $DOTFILES_REPO_ADDRESS ]] && echo "Failed to get repository address" && exit 1;
    );

    # Export variables
    export DOTFILES_DIR="$DOTFILES_DIR"
    export DOTFILES_REPO_ADDRESS="$DOTFILES_REPO_ADDRESS"
}

# Link .*rc to corresponding dotfile rc's.
install_rcfiles() {
    for rc in $(ls ~/.dotfiles/*.rc); do
        rclink=${rc%.rc}
        rclink=${rclink#$DOTFILES_DIR}
        rclink=${rclink#/}
        rclink="$HOME/.$rclink"
        echo "I should link $rc to $rclink"
        if [[ -e $rclink ]]; then
            if [[ -L $rclink ]]; then
                rm $rclink
            else
                mv $rclink $rclink.old
            fi
        fi
        ln -s $rc $rclink
    done
}

prepare() {
    check_variables;
    check_repo;
}

