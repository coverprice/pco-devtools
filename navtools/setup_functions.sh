#!/usr/bin/env bash
# NB: This must only contain functions, it should not execute anything.

SETUP_NAVTOOLS_HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"${HOME}/.config"}"
NAVTOOLS_CONFIG_FILE="${XDG_CONFIG_HOME}/pco_devtools/pco_devtools.conf.sh"


function _ensure_navtools_config_exists() {
  local - config_dir
  set -o nounset -o pipefail

  if [[ ! -f $NAVTOOLS_CONFIG_FILE ]]; then
    echo "${NAVTOOLS_CONFIG_FILE} does not exist, creating from defaults."
    config_dir="$(dirname "${NAVTOOLS_CONFIG_FILE}")"
    [[ ! -d $config_dir ]] && mkdir -p "${config_dir}"
    cp "${SETUP_NAVTOOLS_HERE}/../configs/pco_devtools.conf.defaults.sh" "${NAVTOOLS_CONFIG_FILE}"
  fi
}


function _load_navtools() {
  local -
  set -o nounset -o pipefail

  _ensure_navtools_config_exists
  source "${NAVTOOLS_CONFIG_FILE}"

  if [[ -z "${PCO_REPO_DIR:-}" ]] || [[ -z "${PCO_VENV_DIR:-}" ]] ; then
    echo "WARNING: Misconfiguration PCO_REPO_DIR and PCO_VENV_DIR are not set."
    echo "Consult the README.md in ${SETUP_NAVTOOLS_HERE}/../README.md"
    return
  fi

  [[ ! -d "${PCO_REPO_DIR}" ]] && mkdir -p "${PCO_REPO_DIR}"
  [[ ! -d "${PCO_VENV_DIR}" ]] && mkdir -p "${PCO_VENV_DIR}"

  source "${SETUP_NAVTOOLS_HERE}/colors.sh"
  source "${SETUP_NAVTOOLS_HERE}/git.sh"
  source "${SETUP_NAVTOOLS_HERE}/project.sh"
  source "${SETUP_NAVTOOLS_HERE}/repo.sh"
  source "${SETUP_NAVTOOLS_HERE}/venv.sh"
  source "${SETUP_NAVTOOLS_HERE}/cd.sh"
  source "${SETUP_NAVTOOLS_HERE}/prompt.sh"
  source "${SETUP_NAVTOOLS_HERE}/usage.sh"

  # Install auto-complete functions
  complete -o default -o bashdefault -F _repo_autocomplete repo
  complete -o default -o bashdefault -F _venv_autocomplete venv
  complete -o default -o bashdefault -F _cdd_autocomplete cdd

  # Auto-activate venv when we enter the directory
  _venv_auto_activate
  PROMPT_COMMAND=pco_prompt_update
}
