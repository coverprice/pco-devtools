#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
INSTALL_NAVTOOLS_HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source "${INSTALL_NAVTOOLS_HERE}/check_bash_version.sh"
source "${INSTALL_NAVTOOLS_HERE}/navtools/setup_functions.sh"


function install_pco_navtools {
  _ensure_navtools_config_exists

  # NB: the zzzz_ prefix here is to ensure that this runs *after* pyenv.sh. Otherwise,
  # pyenv will point the Python executable at the global pyenv shim, rather than the active venv's Python.
  local install_target=~/.bashrc.d/zzzz_load_pco_navtools.sh
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
