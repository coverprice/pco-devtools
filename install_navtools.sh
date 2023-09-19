#!/bin/bash

set -o errexit -o nounset -o pipefail
INSTALL_NAVTOOLS_HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"


function install_pco_navtools {
  local config_env="${INSTALL_NAVTOOLS_HERE}/configs/pco_devtools.conf.sh"
  local config_env_defaults="${INSTALL_NAVTOOLS_HERE}/configs/pco_devtools.conf.defaults.sh"
  local install_target=~/.bashrc.d/load_pco_navtools.sh

  if [[ ! -f $config_env ]]; then
    echo "pco_devtools.conf.sh does not exist, creating from defaults: ${config_env_defaults}"
    cp "${config_env_defaults}" "${config_env}"
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
