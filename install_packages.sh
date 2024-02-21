#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
INSTALL_PACKAGES_HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source "${INSTALL_PACKAGES_HERE}/check_bash_version.sh"


function fedora_linux_install() {
  echo "Ensuring critical RPMs are installed."
  # gh: the Github CLI tool
  # ncurses: provides 'tput', which is used for coloring the prompt
  # p11-kit-trust: provides 'trust', used for inspecting the contents of the CA certificate bundle

  if ! rpm -q dnf-plugins-core >/dev/null 2>&1 || ! sudo dnf repolist | grep -q ^hashicorp ; then
    sudo dnf install --assumeyes dnf-plugins-core
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
  fi

  declare -a packages=(
    ack                       # Dev tool: Search text files for strings quickly (similar to grep)
    coreutils
    curl
    findutils                 # Includes `find`, which is commonly-used
    gcc                       # Needed to compile specific Python versions
    gdbm-devel                # Needed to compile specific Python versions
    gh                        # Github CLI client, needed for some infra-toolbox scripts
    git
    jq
    libffi-devel              # Needed to compile specific Python versions
    ncurses
    ncurses-devel             # Needed to compile specific Python versions
    npm                       # Used for Atlas development
    openssl
    openssl-devel             # Needed to compile specific Python versions
    p11-kit-trust             # Needed to compile specific Python versions
    podman
    postgresql-server         # Used for Atlas development
    readline-devel            # Needed to compile specific Python versions
    redis                     # Used for Atlas development
    sed
    ShellCheck                # Shell script linter
    sqlite-devel              # Needed to compile specific Python versions
    the_silver_searcher       # Dev tool: Search text files for strings quickly (similar to grep)
    tmux                      # Shell window management
    uwsgi                     # Web server: Used for Atlas development
    uwsgi-plugin-python3
    uwsgi-router-http
    vagrant                   # Used to stand up local VMs for development
    vault                     # Hashicorp Vault client
    vim-ale                   # VIM editor syntax highlighting system
    vim-enhanced
    xmlsec1-openssl           # Needed to compile specific Python versions
    xz-devel                  # Needed to compile specific Python versions
    yarnpkg                   # Used for Atlas development
    zlib-devel                # Needed to compile specific Python versions
  )
  declare -a packages_to_install=()
  for package in "${packages[@]}" ; do
    if ! rpm -q "${package}" >/dev/null 2>&1 ; then
      packages_to_install+=("${package}")
    fi
  done
  if [[ "${#packages_to_install[@]}" -gt 0 ]] ; then
    set -o xtrace
    sudo dnf install --assumeyes "${packages_to_install[@]}"
    set +o xtrace
  fi


  # Initialize Postgres
  if ! sudo systemctl is-enabled --quiet postgresql.service ; then
    set -o xtrace
    # Configure Postgres to accept md5 authentication
    if sudo test ! -f "/var/lib/pgsql/data/pg_hba.conf"; then
      sudo /usr/bin/postgresql-setup --initdb

      # Update the "host    all             all             127.0.0.1/32            ident" line to use md5 instead:
      #            "host    all             all             127.0.0.1/32            md5"
      sudo sed -i -E 's#^(host\s+all\s+all\s+127.0.0.1/32\s+)ident$#\1md5#g' /var/lib/pgsql/data/pg_hba.conf
    fi

    sudo systemctl enable --now postgresql.service
    set +o xtrace
  fi

  # Enable the Redis service
  if ! sudo systemctl is-enabled --quiet redis.service ; then
    set -o xtrace
    sudo systemctl enable --now redis.service
    set +o xtrace
  fi
}


function macos_install() {
  ensure_brew_installed
  ensure_bash_configured

  # Some packages are pre-installed by MacOS so they may be missing when compared to the DNF list above:
  # - openssl
  # - vim
  # Some packages are not available via Brew so are installed by the function that configures them:
  # - vim-ale
  local packages_to_install=()
  for package in ack jq gh shellcheck tmux vagrant ; do
    if ! command -v "${package}" >/dev/null ; then
      packages_to_install+=("${package}")
    fi
  done

  # MacOS uses an ancient version of find / xargs.
  if find . -printf '%s' 2>&1 | grep "unknown primary or operator" >/dev/null ; then
    packages_to_install+=("findutils")
  fi

  if ! command -v tput >/dev/null ; then
    packages_to_install+=("ncurses")
  fi

  if ! command -v ag >/dev/null ; then
    packages_to_install+=("the_silver_searcher")
  fi

  if ! command -v vault >/dev/null ; then
    brew tap hashicorp/tap
    brew install hashicorp/tap/vault
  fi

  if [[ "${#packages_to_install[@]}" -gt 0 ]]; then
    set -o xtrace
    brew install "${packages_to_install[@]}"
    set +o xtrace
  fi
}


function ensure_bash_configured() {
  [[ ! -d ~/.bashrc.d ]] && mkdir -p ~/.bashrc.d

  if [[ ! -f ~/.bashrc ]]; then
    # Install skeleton .bashrc if one is not present
    cat >> ~/.bashrc <<"EOF"
# Source global definitions
if [[ -f /etc/bashrc ]]; then
  source /etc/bashrc
fi
# User specific aliases and functions
if [[ -d ~/.bashrc.d ]]; then
  for rc in ~/.bashrc.d/*; do
    if [[ -f "$rc" ]]; then
      # shellcheck disable=SC1090
      source "$rc"
    fi
  done
fi
unset rc
EOF
  fi

  # Stop the annoying zsh default shell warning
  if [[ ! -f ~/.bash_profile ]] || ! grep -E BASH_SILENCE_DEPRECATION_WARNING ~/.bash_profile >/dev/null 2>&1 ; then
    echo "export BASH_SILENCE_DEPRECATION_WARNING=1" >> ~/.bash_profile
  fi
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
