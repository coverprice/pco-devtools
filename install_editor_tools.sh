#!/bin/bash
#
# Install editor-related tools and configs

set -o errexit -o nounset -o pipefail
INSTALL_EDITOR_TOOLS_HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"


function ensure_tmux_installed() {
  if [[ -f ~/.tmux.conf ]]; then
    echo "Skipping: adding tmux config. Tmux config already present."

  else
    echo "Missing tmux configuration. Installing basic configuration into ~/.tmux.conf"
    cp "${INSTALL_EDITOR_TOOLS_HERE}/configs/tmux.sample.conf" ~/.tmux.conf
  fi
}


function ensure_vimrc_configured() {
  if [[ -f ~/.vimrc ]]; then
    echo "Skipping: adding vim config. Vim config already present."

  else
    echo "Missing vim configuration. Installing basic configuration into ~/.vimrc"
    cp "${INSTALL_EDITOR_TOOLS_HERE}/configs/vim/vimrc.sample.vim" ~/.vimrc
    return
  fi
}


function ensure_vim_ale_configured() {
  local macos_ale_install_dir=~/.vim/pack/git-plugins/start/ale
  if [[ "$(uname)" == "Linux" ]] && ! rpm -q vim-ale >/dev/null 2>&1 ; then
    echo "Skipping: vim-ale RPM is not present. Use install_packages.sh script to install"
    return 0
  elif [[ "$(uname)" == "Darwin" ]] && [[ ! -d "${macos_ale_install_dir}/.git" ]] ; then
    mkdir -p "${macos_ale_install_dir}"
    git clone --depth 1 https://github.com/dense-analysis/ale.git "${macos_ale_install_dir}"
  fi

  local config_file
  config_file=~/.vim/plugin/ale.vim
  if [[ -f $config_file ]]; then
    echo "Skipping: adding Vim ale config. Vim ale config already present."

  else
    echo "Installing Vim ale config."
    mkdir -p "$(dirname "${config_file}")"
    cp "${INSTALL_EDITOR_TOOLS_HERE}/configs/vim/ale.vim" "${config_file}"
  fi
}


function ensure_vim_black_installed() {
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
      cp "${INSTALL_EDITOR_TOOLS_HERE}/configs/vim/black.vim" "${config_dir}"
    fi

    vim -c :Black -c :q		# Run vim to install Black and immediately quit
  fi 
}


function install_editor_configs() {
  source "${INSTALL_EDITOR_TOOLS_HERE}/install_packages.sh"
  ensure_tmux_installed
  ensure_vimrc_configured
  ensure_vim_ale_configured
  ensure_vim_black_installed
}


install_editor_configs
