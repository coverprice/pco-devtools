#!/usr/bin/env bash
# Purpose: Examines the current repo (assuming the current directory is in one), and extracts various attributes
#          into envvars.
# INPUT:
#   $1 - str "--silent" if present, do not output any errors, just exit silently
#   $PCO_REPO_DIR - str - Absolute path to where all repos are located
#   $PCO_VENV_DIR - str - Absolute path to where all venvs are located
# OUTPUT:
#   @return
#      _REPO_TOP - envvar string - Absolute path to top dir of current git repo. Empty if not in a git repo.
#      _REPO_IS_MONOREPO - envvar string - `true` if this is infra-toolbox, `false` for all other repos.
#      _REPO_METADATA_PATH - Absolute path to directory where this repo's venvs and other metadata is stored.
#      _REPO_ACTIVE_PROJECT_DIR - envvar string - the path (relative to the top of the current repo) of the current
#           Active Project. (This doesn't imply the Active Project's venv exists or is activated)
function _analyze_current_repo() {
  local silent="${1:-}" output_errors=true
  local output_errors=true
  unset _REPO_TOP
  unset _REPO_IS_MONOREPO
  unset _REPO_METADATA_PATH
  unset _REPO_ACTIVE_PROJECT_DIR

  if [[ $silent == "--silent" ]]; then
    output_errors=false
  fi
  _REPO_TOP="$(git rev-parse --path-format=absolute --show-toplevel 2>/dev/null)"

  if [[ -z $_REPO_TOP ]] ; then
    $output_errors && echo "ERROR: Not currently within in a git repo"
    return
  fi

  if [[ -d "${_REPO_TOP}/apps/atlas" ]] ; then
    _REPO_IS_MONOREPO=true
  else
    _REPO_IS_MONOREPO=false
  fi

  if [[ "${_REPO_TOP#"${PCO_REPO_DIR}/"}" == "${_REPO_TOP}" ]] ; then
    $output_errors && echo "ERROR: Git repo not currently under dir: ${PCO_REPO_DIR}"
    return
  fi

  _REPO_METADATA_PATH="${PCO_VENV_DIR}/$(basename "${_REPO_TOP}")"
  if [[ ! -d $_REPO_METADATA_PATH ]] ; then
    mkdir -p "${_REPO_METADATA_PATH}"
  fi

  local active_project_store="${_REPO_METADATA_PATH}/active_project.txt"
  if [[ -f $active_project_store ]]; then
    _REPO_ACTIVE_PROJECT_DIR="$(<"${active_project_store}")"
    if [[ ! -d "${_REPO_TOP}/${_REPO_ACTIVE_PROJECT_DIR}" ]]; then
      # Contents of the active_project.txt don't point to a valid dir, so unset this.
      unset _REPO_ACTIVE_PROJECT_DIR
    fi
  fi
}
