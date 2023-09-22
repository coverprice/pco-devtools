#!/usr/bin/env bash
# =====================================================
# Functions for navigating within a PCO repo
# =====================================================


# cd to the current venv's installed Python libaries. (Useful for inspecting source code of Python packages)
function cdpylibs() {
  if [[ -z "${VIRTUAL_ENV:-}" ]] ; then
    echo "ERROR: No virtualenv is currently activated."
    return
  fi

  local - dir
  dir="$(python -c "import sys; print(list(filter(lambda x:x.endswith('/site-packages'),sys.path))[0])")"
  if [[ ! -d $dir ]]; then
    echo "ERROR: ${dir} does not exist"
    return
  fi
  cd "${dir}" || return
}


# [infra-toolbox ONLY] Change directory to the given PROJECT ('atlas', 'aws-pruner', 'dpp-utils', ...)
# PROJECT is auto-completable with Tab.
#
# Usage:
#   cdd PROJECT
# Example:
#   cdd dpp-utils
function cdd() {
  local project="${1:-}"
  _analyze_current_repo
  [[ -z "${_REPO_TOP:-}" ]] && return
  if $_REPO_IS_MONOREPO ; then
    if [[ -z $project ]]; then
      cd "${_REPO_TOP}" || return
    elif [[ -d "${_REPO_TOP}/apps/${project}" ]]; then
      cd "${_REPO_TOP}/apps/${project}" || return
    elif [[ -d "${_REPO_TOP}/libs/${project}" ]]; then
      cd "${_REPO_TOP}/libs/${project}" || return
    else
      echo "ERROR: no such project ${project}" || return
    fi
  else
    cd "${_REPO_TOP}" || return
  fi
}


function _cdd_autocomplete() {
  # This autocompletes the 'venv go <dpp-project>'
  # shellcheck disable=SC2034
  local command_name="${1:-}" word_being_completed="${2:-}" word_preceding="${3:-}"
  unset COMPREPLY

  _get_project_options
  [[ ! -v _PROJECT_OPTIONS ]] && return
  mapfile -t COMPREPLY < <(compgen -W "${_PROJECT_OPTIONS[*]}" "${word_being_completed}")
}


# cd to the top of the git repo
function cdtop() {
  local git_top
  git_top="$(git rev-parse --show-toplevel 2>/dev/null)"
  if [[ -z $git_top ]] ; then
    echo "Current directory is not in a git repo"
    return
  fi
  cd "${git_top}" || return
}


# [infra-toolbox ONLY] cd to Atlas's main work directory
function cdat() {
  _analyze_current_repo
  [[ -n "${_REPO_TOP:-}" ]] && $_REPO_IS_MONOREPO && cd "${_REPO_TOP}/apps/atlas/atlas" || return
}


# [infra-toolbox ONLY] cd to the support-toolkit directory (and activate the venv)
function cdsup() {
  _analyze_current_repo
  if [[ -n "${_REPO_TOP:-}" ]] && $_REPO_IS_MONOREPO ; then
    cd "${_REPO_TOP}/apps/support-toolkit" || return
    _venv_on
  else
    return 1
  fi
}
