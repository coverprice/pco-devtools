#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
INSTALL_NAVTOOLS_HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source "${INSTALL_NAVTOOLS_HERE}/check_bash_version.sh"


function install_pco_navtools {
  XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"${HOME}/.config"}"
  local navtools_config="${XDG_CONFIG_HOME}/pco_devtools.conf.sh"
  local navtools_config_defaults="${INSTALL_NAVTOOLS_HERE}/configs/pco_devtools.conf.defaults.sh"
  local install_target=~/.bashrc.d/load_pco_navtools.sh

  if [[ ! -f $navtools_config ]]; then
    echo "pco_devtools.conf.sh does not exist, creating from defaults: ${navtools_config_defaults}"
    [[ ! -d $XDG_CONFIG_HOME ]] && mkdir -p "${XDG_CONFIG_HOME}"
    cp "${navtools_config_defaults}" "${navtools_config}"
  fi

  [[ ! -d ~/.bashrc.d ]] && mkdir -p ~/.bashrc.d

  if [[ ! -f $install_target ]]; then
    echo "Installing PCO navtools into ${install_target}"
    cat > "${install_target}" <<EOF
_pco_navtools="${INSTALL_NAVTOOLS_HERE}/navtools/load.sh"
[[ -f \$_pco_navtools ]] && source "\${_pco_navtools}"
EOF
  fi
}


install_pco_navtools
