#!/usr/bin/env bash

dotfiles_create_tempdir(){
  DOTFILES_DIR=$(mktemp -d)
  export DOTFILES_DIR
}

dotfiles_prepare_setup(){
  [[ -z $DOTFILES_DIR ]] && dotfiles_create_tempdir
  [[ -z $DOTFILES_REPO ]] && DOTFILES_REPO="https://github.com/TLii/dotfiles.git"
  export DOTFILES_REPO
  [[ -d $DOTFILES_DIR ]] || mkdir -p $DOTFILES_DIR
  git clone -q "$DOTFILES_REPO" "$DOTFILES_DIR" || echo "Failed to clone repository" && exit 1;
  rm -r "$DOTFILES_DIR"
}

dotfiles_setup() {
  source "$DOTFILES_DIR"/dotfiles.lib.sh
}

dotfiles_config(){
  while true; do
    echo "Currently using dotfile repository $DOTFILES_REPO"
    read -p "Do you want to use a custom repository?"
  done
}

dotfiles_prompt() {
  bold=$(tput bold)
  normal=$(tput sgr0)

  cat <<EOF
############### DOTFILES AUTOMATIC INSTALLER ###############

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
      read -p "Which one do you wish to choose? (1 or 2, 0 exits immediately)" decide
      case $decide in
          [1]* ) 
            echo "Install with sources"
#            dotfiles_config
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

dotfiles_silent_run(){
  dotfiles_prepare_setup
}

dotfiles_runner(){
  if [ -t 0 ]; then
    dotfiles_prompt
  else
    dotfiles_silent_run
  fi
}

dotfiles_runner
