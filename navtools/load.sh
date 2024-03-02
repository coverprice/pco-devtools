#!/usr/bin/env bash
PCO_NAVTOOLS_HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

function _load_navtools() {
  local -
  set -o nounset -o pipefail

  local config_dir
  local config_env=~/.config/pco_devtools/pco_devtools.conf.sh
  local config_env_defaults="${PCO_NAVTOOLS_HERE}/configs/pco_devtools.conf.defaults.sh"

  if [[ ! -f $config_env ]]; then
    echo "${config_env} does not exist, creating from defaults."
    config_dir="$(dirname "$(readlink -f "${config_env}")")"
    [[ ! -d $config_dir ]] && mkdir -p "${config_dir}"
    cp "${config_env_defaults}" "${config_env}"
  fi
  source "${config_env}"

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
