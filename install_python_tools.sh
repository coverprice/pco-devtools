#!/bin/bash

set -o errexit -o pipefail
# shellcheck disable=SC2034
INSTALL_PYTHON_TOOLS_HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"


function ensure_pyenv_installed {
  local -
  set -o nounset

  if command -v pyenv > /dev/null ; then
    echo "Skipping: Pyenv already installed"

  else
    echo "Installing Pyenv"
    # See https://github.com/pyenv/pyenv-installer
    curl --silent --show-error --location https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
  fi

  # Ensure that the pyenv config loader is installed

  local found_pyenv_config_loader=false
  for profile in ~/.bashrc ~/.bash_profile ~/.profile ~/.bash_login ; do
    if [[ -f $profile ]] && grep -E 'export PYENV_ROOT=' "${profile}" >/dev/null 2>&1 ; then
      found_pyenv_config_loader=true
      break
    fi
  done
  if $found_pyenv_config_loader ; then
    echo "Skipping: Pyenv config loader already installed"

  else
    echo "Installing Pyenv config loader"
    # Adapted from https://github.com/pyenv/pyenv#set-up-your-shell-environment-for-pyenv
    # Which recommends installing it in both .bash_profile and .bashrc (via .bashrc.d)
    cat >> ~/.bash_profile <<"EOF"
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
    [[ ! -d ~/.bashrc.d ]] && mkdir -p ~/.bashrc.d
    cat >> ~/.bashrc.d/pyenv.sh <<"EOF"
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
    echo "Re-sourcing bash profile"
    set +o nounset
    # shellcheck disable=SC1090
    source ~/.bash_profile
  fi
  echo "Completed Installing Pyenv config loader"
}


function ensure_python_installed {
  local -
  set -o nounset

  if ! command -v pyenv > /dev/null ; then
    echo "Error: Cannot install Python. pyenv is not installed / configured."
    exit 1
  fi

  if pyenv versions --bare | grep -E '^3\.9\.' >/dev/null 2>&1 ; then
    echo "Python 3.9 already installed."
  else
    echo "Installing Python 3.9 (this may take some time)"
    pyenv install 3.9
  fi 

  pyenv global 3.9

  local py_version regex='^Python 3\.9\.'
  py_version="$(python --version)"
  if [[ ! $py_version =~ $regex ]] ; then
    echo "Error: Python 3.9 is installed but running 'python --version' is showing: '${py_version}'"
    exit 1
  fi
}


function ensure_poetry_installed {
  local -
  set -o nounset

  if command -v poetry  > /dev/null ; then
    echo "Skipping: Poetry already installed:"
    poetry --version
    return 0
  fi

  if [[ -n ${VIRTUAL_ENV:-} ]] || [[ "$(which python)" =~ venv ]]; then
    echo "Error: Virtual environment detected. Cannot run the Poetry install from within a Virtualenv."
    echo "Please run 'deactivate' and re-run this script."
    exit 1
  fi

  echo "Installing Poetry."
  # Instructions verbatim from https://python-poetry.org/docs/
  curl --silent --show-error --location https://install.python-poetry.org | python3 -

  # The venv manager takes care of creating venvs, not poetry. This is because Poetry will (by default) put its venvs
  # inside the pyproject.toml project directory, which can cause some issues.
  poetry config virtualenvs.create false
}


function main {
  ensure_pyenv_installed
  ensure_python_installed
  ensure_poetry_installed
}


main
