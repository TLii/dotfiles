#!/usr/bin/env bash

######### DOTFILE FUNCTIONS ########

# Check if dotfiles are installed; if not, install and if yes, update.

dotfiles_prepare_variables(){
  [[ -z $DOTFILES_REPO ]] && DOTFILES_REPO="https://github.com/TLii/dotfiles.git"
  if [[ -z $DOTFILES_DIR ]]; then
    DOTFILES_DIR=$(mktemp -d);
    DOTFILES_USE_TMP=true;
  fi

  # Export variables
  export DOTFILES_DIR="$DOTFILES_DIR"
  export DOTFILES_REPO_ADDRESS="$DOTFILES_REPO_ADDRESS"
}

dotfiles_install_repo(){
  [[ -d $DOTFILES_DIR ]] || mkdir -p "$DOTFILES_DIR";
  git clone -q $DOTFILES_REPO "$DOTFILES_DIR" || \echo "Failed to install dotfiles" && exit 1;
}

dotfiles_update_repo(){
  if git -C "$DOTFILES_DIR" rev-parse 2>/dev/null; then
  git pull -q "$DOTFILES_REPO" "$DOTFILES_DIR"
}

# Ensure environment variables exist.
dotfiles_check_repo() {
  elif [[ ! -d $DOTFILES_DIR ]]; then
    mkdir -p $DOTFILES_DIR
  elif [[ -d

  DOTFILES_DIR="${DOTFILES_DIR%/}";


      git pull -q https://github.com/TLii/dotfiles.git "$DOTFILES_DIR" || echo "Failed to update dotfiles";

  fi


}


# Link .*rc to corresponding dotfile rc's.
dotfiles_link_files() {
    for rc in "$DOTFILES_DIR"/*.rc; do
        rclink=${rc%.rc}
        rclink=${rclink#$DOTFILES_DIR}
        rclink=${rclink#/}
        rclink="$HOME/.$rclink"
        if [[ -e $rclink ]]; then
            if [[ -L $rclink ]]; then
                rm "$rclink"
            else
                mv "$rclink" "$rclink.old"
            fi
        fi
        ln -s "$rc" "$rclink"
    done
}

dotfiles_copy_files() {

    for rc in "$DOTFILES_DIR"/*.rc; do
        rclink=${rc%.rc}
        rclink=${rclink#$DOTFILES_DIR}
        rclink=${rclink#/}
        rclink="$HOME/.$rclink"
  done

}

dotfiles_prepare() {
    dotfiles_prepare_variables;
    dotfiles_manage_repo;
}

dotfiles_install() {
  if $DOTFILES_USE_TMP; then
    dotfiles_copy_files
  else
    dotfiles_link_files
  fi
}
