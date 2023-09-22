#!/bin/bash

set -o errexit -o nounset -o pipefail
INSTALL_DEVTOOLS_HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"


function ensure_git_credential_helper_installed() {
  if [[ -f ~/.gitconfig ]] && grep -E 'helper\s*=\s*store$' ~/.gitconfig >/dev/null 2>&1 ; then
    echo "Skipping: Git credential helper already configured."
    return 0
  fi

  echo "Ensuring Git credential helper is activated."
  cd "${HOME}"
  git config --global credential.helper store
}


function ensure_root_ca_installed() {
  # See instructions from
  # https://source.redhat.com/groups/public/identity-access-management/rhcs_red_hat_certificate_system_wiki/faqs_new_corporate_root_certificate_authority
  if [[ -f "/etc/pki/ca-trust/source/anchors/Current-IT-Root-CAs.pem" ]] ; then
    echo "Skipping: Root CA bundle appears to be installed."
    return 0
  fi

  echo "Installing Root CA bundle."
  sudo cp "${INSTALL_DEVTOOLS_HERE}/configs/Current-IT-Root-CAs.pem" "/etc/pki/ca-trust/source/anchors/"
  sudo update-ca-trust
}


function ensure_secrets_dir_exists() {
  if [[ -d ~/.secrets ]]; then
    echo "Skipping: ~/.secrets already exists."

  else
    echo "Creating ~/.secrets"
    mkdir ~/.secrets
  fi
}


function install_devtools() {
  source "${INSTALL_DEVTOOLS_HERE}/install_packages.sh"
  ensure_root_ca_installed
  ensure_git_credential_helper_installed
  ensure_secrets_dir_exists
}


install_devtools
