#!/usr/bin/env bash
# INPUT: None
# OUTPUT:
#   @return _PROJECT_OPTIONS - envvar array - an array of the project names available in the repo (projects are under /apps and /libs,
#   e.g. 'atlas', 'aws-pruner', ..., 'dpp-utils'). This is used for autocomplete.
function _get_project_options() {
  unset _PROJECT_OPTIONS
  [[ ! -v _REPO_TOP ]] && _analyze_current_repo
  [[ -z "${_REPO_TOP:-}" ]] && return
  if ! $_REPO_IS_MONOREPO ; then
    return
  fi
  mapfile -t _PROJECT_OPTIONS < <(find "${_REPO_TOP}/apps" "${_REPO_TOP}/libs" -mindepth 1 -maxdepth 1 -type d -printf "%f\n")
}


# INPUT: None
# OUTPUT:
#   @return _PROJECT_PATH - envvar string - path (relative to the top of the git repo) to the project the current dir
#                                           belongs to, or empty.
function _find_nearest_project_dir() {
  _PROJECT_PATH=
  [[ ! -v _REPO_TOP ]] && _analyze_current_repo
  [[ -z "${_REPO_TOP:-}" ]] && return

  local cur_dir
  cur_dir="${PWD}"
  while [[ $cur_dir != "${_REPO_TOP}" ]] && [[ $cur_dir != "/" ]] ; do
    if [[ -f "${cur_dir}/pyproject.toml" ]] || [[ -f "${cur_dir}/requirements.txt" ]] ; then
      # Return the project path, relative to the top of the repo.
      _PROJECT_PATH="${cur_dir#"${_REPO_TOP}/"}"
      if [[ "${_PROJECT_PATH}" == "${cur_dir}" ]] ; then
         echo "ERROR: assert failure. _REPO_TOP was not correctly stripped as a prefix from cur_dir: ${cur_dir}"
         return 1
      fi
      return
    else
      cur_dir=$(dirname "${cur_dir}")
    fi
  done
}


# Tries to determine what project to automatically activate.
# Must be called when the current directory is inside a repo.
# - For regular repos, this means the "top" project (".")
# - For monorepos, it will look at the current directory and work its way towards the top
#     until it finds an app/lib project dir. If it does not find one, then it tries
#     to use the project name stored in "$PCO_VENV_DIR/$REPO_NAME/active_project.txt"
#
# INPUT:
#   _REPO_TOP et al
# OUTPUT:
#   _PROJECT_PATH_TO_ACTIVATE - envvar string - path relative to _REPO_TOP (empty if it couldn't find one)
function _determine_project_to_activate() {
  _PROJECT_PATH_TO_ACTIVATE=
  [[ ! -v _REPO_TOP ]] && _analyze_current_repo
  [[ -z "${_REPO_TOP:-}" ]] && return
  if $_REPO_IS_MONOREPO ; then
    _find_nearest_project_dir
    if [[ -n "${_PROJECT_PATH:-}" ]] ; then
      _PROJECT_PATH_TO_ACTIVATE="${_PROJECT_PATH}"
    else
      # We're in a repo, but not in a project dir. So try to use the current active project if it exists.
      if [[ -n "${_REPO_ACTIVE_PROJECT_DIR:-}" ]] && [[ -d "${_REPO_TOP}/${_REPO_ACTIVE_PROJECT_DIR:-}" ]] ; then
        _PROJECT_PATH_TO_ACTIVATE="${_REPO_ACTIVE_PROJECT_DIR}"
      fi
    fi
  else
    _PROJECT_PATH_TO_ACTIVATE="."
  fi
}
