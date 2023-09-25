#!/usr/bin/env bash
PCO_NAVTOOLS_HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

function _load_navtools() {
  local - navtools_config
  set -o nounset -o pipefail

  navtools_config="${PCO_NAVTOOLS_HERE}/../configs/pco_devtools.conf.sh"
  if [[ ! -f $navtools_config ]]; then
    echo "Navtools config file not found in ${navtools_config}, copying from defaults."
    cp "${PCO_NAVTOOLS_HERE}/../configs/pco_devtools.conf.defaults.sh" "${navtools_config}"
  fi
  source "${navtools_config}"

  if [[ -z "${PCO_REPO_DIR:-}" ]] || [[ -z "${PCO_VENV_DIR:-}" ]] ; then
    echo "WARNING: Misconfiguration PCO_REPO_DIR and PCO_VENV_DIR are not set."
    echo "Consult the README.md in ${PCO_NAVTOOLS_HERE}/../README.md"
    return
  fi

  [[ ! -d "${PCO_REPO_DIR}" ]] && mkdir -p "${PCO_REPO_DIR}"
  [[ ! -d "${PCO_VENV_DIR}" ]] && mkdir -p "${PCO_VENV_DIR}"

  source "${PCO_NAVTOOLS_HERE}/colors.sh"
  source "${PCO_NAVTOOLS_HERE}/git.sh"
  source "${PCO_NAVTOOLS_HERE}/project.sh"
  source "${PCO_NAVTOOLS_HERE}/repo.sh"
  source "${PCO_NAVTOOLS_HERE}/venv.sh"
  source "${PCO_NAVTOOLS_HERE}/cd.sh"
  source "${PCO_NAVTOOLS_HERE}/prompt.sh"
  source "${PCO_NAVTOOLS_HERE}/usage.sh"

  # Install auto-complete functions
  complete -o default -o bashdefault -F _repo_autocomplete repo
  complete -o default -o bashdefault -F _venv_autocomplete venv
  complete -o default -o bashdefault -F _cdd_autocomplete cdd

  # Auto-activate venv when we enter the directory
  _venv_auto_activate
  PROMPT_COMMAND=pco_prompt_update
}

_load_navtools
