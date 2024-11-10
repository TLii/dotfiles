#!/usr/bin/env bash

#    Dotfiles installer
#    Copyright (C) 2024  Tuomas Liinamaa <tlii@iki.fi>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

source lib_help.sh
source lib_setup.sh


dotfiles_cleanup(){
  rm -r "$DOTFILES_DIR"
}

dotfiles_check_config(){

  # Source config files
  if [[ -f "$PWD/dotfiles.conf" ]]; then
    source "$PWD/dotfiles.conf"
  elif [[ -f "$HOME/.dotfiles.conf" ]]; then
    source "$HOME/.dotfiles.conf"
  fi

  # Set default variables
  [[ -z $DOTFILES_REPO ]] && DOTFILES_REPO="https://github.com/TLii/dotfiles.git"
  if [[ -z $DOTFILES_DIR ]]; then
    DOTFILES_DIR=$(mktemp -d);
    DOTFILES_USE_TMP=true;
  fi

  # Export variables
  export DOTFILES_DIR="$DOTFILES_DIR"
  export DOTFILES_REPO_ADDRESS="$DOTFILES_REPO_ADDRESS"

}

dotfiles_silent_run(){
  # Silent setup runner
  dotfiles_check_config
}

dotfiles_main(){

  method=$(echo "$1" | awk '{print tolower($0)}')
  topic=$(echo "$2" | awk '{print tolower($0)}')

  # Check for interactive terminal and run method
  if [[ $method == "install" ]]; then
    if [ -t 0 ]; then
      # If terminal, launch prompted setup
      dotfiles_install_prompt
    else
      dotfiles_silent_install
    fi
  elif [[ $method == "update" ]] && [ -t 0 ]; then
    # Run updater
      dotfiles_header
      dotfiles_check_config
  elif [[ $method == "help" ]] && [ -t 0 ]; then
    # Run updater
    dotfiles_header
    dotfiles_help "$topic"
  elif [ -t 0 ]; then
    echo "Usage: $0 [install|update]"
    exit 0
  else
    # If no terminal and no method, run silently
    dotfiles_silent_run
    dotfiles_cleanup
  fi
}


dotfiles_main "$1" "$2"




dotfiles_install_repo(){
  [[ -d $DOTFILES_DIR ]] || mkdir -p "$DOTFILES_DIR";
  git clone -q "$DOTFILES_REPO" "$DOTFILES_DIR" || \echo "Failed to install dotfiles" && exit 1;
}

dotfiles_update_repo(){
  if git -C "$DOTFILES_DIR" rev-parse 2>/dev/null; then
    git pull -q "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
}

# Link .*rc to corresponding dotfile rc's.
dotfiles_link_files() {
    for rc in "$DOTFILES_DIR"/*.rc; do
        rclink=${rc%.rc}
        rclink=${rclink#"$DOTFILES_DIR"}
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
        rclink=${rclink#"$DOTFILES_DIR"}
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

dotfiles_create_tempdir(){
  DOTFILES_DIR=$(mktemp -d)
  export DOTFILES_DIR="$DOTFILES_DIR"
}

dotfiles_prepare_setup(){
  [[ -z $DOTFILES_DIR ]] && dotfiles_create_tempdir
  [[ -z $DOTFILES_REPO ]] && DOTFILES_REPO="https://github.com/TLii/dotfiles.git"
  export DOTFILES_REPO="$DOTFILES_REPO"
  [[ -d $DOTFILES_DIR ]] || mkdir -p "$DOTFILES_DIR"
  git clone -q "$DOTFILES_REPO" "$DOTFILES_DIR" || echo "Failed to clone repository" && exit 1;
}


dotfiles_prompt_config(){
  while true; do
    echo "Currently using dotfile repository $DOTFILES_REPO"
    read -r -p "Do you want to use a custom repository?"
  done
}

dotfiles_install_prompt() {
  bold=$(tput bold)
  normal=$(tput sgr0)

  cat <<EOF

Dotfiles are installed from a Git repository. Choose installation method:
1)  ${bold}Install with sources:${normal} Clone the repository to a persisting directory (e.g. $HOME/dotfiles) and
    link files to their real locations under $HOME.
    If you wish to make changes to the dotfiles, you can push them back to the 
    repository.
2)  Copy files directly to their real locations without a persisting repository.
    Note that your dotfiles will always be overwritten during an update, so you 
    won't be able to persist any changes to files.
0)  Exit immediately.

EOF

  while true; do
      read -r -p "Which one do you wish to choose? (1 or 2, 0 exits immediately)" decide
      case $decide in
          [1]* ) 
            echo "Install with sources"
            dotfiles_config
           
            break
          ;;
          [2]* ) 
              echo "Install without sources"
              dotfiles_prepare_setup
          ;;
          [0]* )
            echo "Exiting..."
            exit 0
          ;;
          * )
            echo "Invalid option. Choose 1 or 2, 0 to exit.";;
      esac
  done

}

