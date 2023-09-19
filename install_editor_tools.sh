#!/bin/bash
#
# Install editor-related tools and configs

set -o errexit -o nounset -o pipefail
INSTALL_TOOLS_HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"


function ensure_dnf_packages_installed {
  local -
  if "${DNF_INSTALL_COMPLETED:-false}" ; then
    return
  fi

  echo "Ensuring critical editor RPMs are installed."
  set -o xtrace
  sudo dnf install --assumeyes \
    ShellCheck \
    tmux \
    vim-enhanced \
    vim-syntastic \
    vim-syntastic-python
  set +o xtrace

  DNF_INSTALL_COMPLETED=true
}


function ensure_tmux_installed {
  ensure_dnf_packages_installed

  if [[ -f ~/.tmux.conf ]]; then
    echo "Skipping: adding tmux config. Tmux config already present."

  else
    echo "Missing tmux configuration. Installing basic configuration into ~/.tmux.conf"
    cp "${INSTALL_TOOLS_HERE}/configs/tmux.sample.conf" ~/.tmux.conf
  fi
}


function ensure_vimrc_installed {
  ensure_dnf_packages_installed

  if [[ -f ~/.vimrc ]]; then
    echo "Skipping: adding vim config. Vim config already present."

  else
    echo "Missing vim configuration. Installing basic configuration into ~/.vimrc"
    cp "${INSTALL_TOOLS_HERE}/configs/vim/vimrc.sample.vim" ~/.vimrc
    return
  fi
}


function ensure_vim_syntastic_installed {
  ensure_dnf_packages_installed

  local config_dir config_file
  config_file=~/.vim/after/plugin/syntastic.vim
  if [[ -f $config_file ]]; then
    echo "Skipping: adding Vim syntastic config. Vim syntastic config already present."

  else
    echo "Installing Vim syntastic config."
    config_dir="$(dirname "${config_file}")"
    mkdir -p "${config_dir}"
    cp "${INSTALL_TOOLS_HERE}/configs/vim/syntastic.vim" "${config_dir}"
  fi
}


function ensure_vim_black_installed {
  ensure_dnf_packages_installed

  if [[ ! -f ~/.vim/pack/python/start/black/plugin/black.vim ]]; then
    echo "Installing Python Black plugin"
    if [[ -n ${VIRTUAL_ENV:-} ]] || [[ "$(which python)" =~ venv ]]; then
      echo "Error: Virtual environment detected. Cannot run the Vim Black install plugin from within a Virtualenv."
      echo "Please run 'deactivate' and re-run this script."
      exit 1
    fi
    # Install the plugin itself
    # Copied from https://black.readthedocs.io/en/stable/integrations/editors.html#vim-8-native-plugin-management
    mkdir -p ~/.vim/pack/python/start/black/plugin
    mkdir -p ~/.vim/pack/python/start/black/autoload
    curl --silent --show-error --location https://raw.githubusercontent.com/psf/black/stable/plugin/black.vim -o ~/.vim/pack/python/start/black/plugin/black.vim
    curl --silent --show-error --location https://raw.githubusercontent.com/psf/black/stable/autoload/black.vim -o ~/.vim/pack/python/start/black/autoload/black.vim

    local config_dir config_file
    config_file=~/.vim/after/ftplugin/python/black.vim
    if [[ ! -f $config_file ]]; then
      echo "Installing Python Black config"
      config_dir="$(dirname "${config_file}")"
      mkdir -p "${config_dir}"
      cp "${INSTALL_TOOLS_HERE}/configs/vim/black.vim" "${config_dir}"
    fi

    vim -c :Black -c :q		# Run vim to install Black and immediately quit
  fi 
}


function main {
  ensure_dnf_packages_installed
  ensure_tmux_installed
  ensure_vimrc_installed
  ensure_vim_syntastic_installed
  ensure_vim_black_installed
}


main
