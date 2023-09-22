#!/bin/bash

set -o errexit -o nounset -o pipefail
# shellcheck disable=SC2034
INSTALL_PACKAGES_HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"


function fedora_linux_install() {
  echo "Ensuring critical RPMs are installed."
  # gh is the github CLI tool
  # ncurses gives us tput, which is used for coloring the prompt
  set -o xtrace
  sudo dnf install --assumeyes \
    jq \
    gh \
    git \
    ncurses \
    openssl \
    ShellCheck \
    tmux \
    vagrant \
    vim-enhanced \
    vim-ale
  set +o xtrace
}


function macos_install() {
  ensure_brew_installed

  # Some packages are pre-installed by MacOS so they may be missing when compared to the DNF list above:
  # - openssl
  # - vim
  # Some packages are not available via Brew so are installed by the function that configures them:
  # - vim-ale
  brew install \
    jq \
    gh \
    ncurses \
    shellcheck \
    tmux \
    vagrant
}


function ensure_brew_installed() {
  if command -v brew >/dev/null ; then
    echo "Skipping: Brew already installed."
    return 0
  fi

  echo "Installing Homebrew."
  # Verbatim from the https://brew.sh website
  curl --fail --silent --show-error --location https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
}


function install_packages() {
  INSTALL_COMPLETE="${INSTALL_COMPLETE:-false}"
  if ${INSTALL_COMPLETE} ; then
    return 0
  fi

  case "$(uname)" in
    Linux)
      fedora_linux_install
      ;;

    Darwin)
      macos_install
      ;;

    *)
      echo "Error: Unknown uname: $(uname)"
      exit 1
      ;;
  esac
  INSTALL_COMPLETE=true
}


install_packages
