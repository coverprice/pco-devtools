#!/usr/bin/env bash
# =======================================================
# Functions for manipulating venvs within a specific repo
# =======================================================
#
function venv() {
  local - command=$1
  shift

  case $command in
    on)
      _venv_on
      ;;
    off)
      _venv_off
      ;;
    destroy)
      _venv_off destroy
      ;;
    go)
      _venv_go "$@"
      ;;
    -h|--help|help|info|usage)
      _navtools_usage
      ;;
    *)
      echo "ERROR: Unknown command '$command'"
      ;;
  esac
}


function _venv_autocomplete {
  # This autocompletes the 'venv go <dpp-project>'

  # shellcheck disable=SC2034
  local command_name="${1}" word_being_completed="${2}" word_preceding="${3}"
  unset COMPREPLY
  if [[ $word_preceding != 'go' ]]; then
    return
  fi
  
  _get_project_options
  [[ ! -v _PROJECT_OPTIONS ]] && return
  mapfile -t COMPREPLY < <(compgen -W "${_PROJECT_OPTIONS[*]}" "${word_being_completed}")
}


# Finds the nearest project directory (or the Repo's Active Project if not found) and activates the venv.
# If there is no venv, it creates one.
# INPUT:
#   NONE
# OUTPUT:
#   VIRTUAL_ENV
function _venv_on() {
  local project_path_to_activate
  _analyze_current_repo
  [[ -z "${_REPO_TOP:-}" ]] && return

  _determine_project_to_activate
  if [[ -z "${_PROJECT_PATH_TO_ACTIVATE:-}" ]]; then
    echo "ERROR: Could not find an appropriate project to activate. Try 'venv go <tab>'"
    return 1
  fi

  _activate_venv "${_PROJECT_PATH_TO_ACTIVATE}"
  _analyze_current_repo
}


# Deactivate the current venv, and remove the "current active project" file
function _venv_off() {
  local destroy="${1}"
  local active_project_store
  _deactivate_venv

  _analyze_current_repo
  [[ -z "${_REPO_TOP:-}" ]] && return 1
  active_project_store="${_REPO_METADATA_PATH}/active_project.txt"
  [[ -e $active_project_store ]] && rm -f "${active_project_store}"

  if [[ $destroy == "destroy" ]] && [[ -n "${_REPO_ACTIVE_PROJECT_DIR:-}" ]] ; then
    local venv_dir="${_REPO_METADATA_PATH}/${_REPO_ACTIVE_PROJECT_DIR}/venv"
    echo "Destroying venv dir: ${venv_dir}"
    [[ -e $venv_dir ]] && _destroy_venv_dir "${venv_dir}"
  fi
  unset _REPO_ACTIVE_PROJECT_DIR
}


# Activate a specific project
#
# INPUT:
#   $1 - string - name of a project (dir name under /apps or /libs)
# OUTPUT:
#   VIRTUAL_ENV
function _venv_go() {
  local project="${1}" project_path_to_activate

  _analyze_current_repo
  [[ -z "${_REPO_TOP:-}" ]] && return

  if [[ -z $project ]] || ! $_REPO_IS_MONOREPO ; then
    _determine_project_to_activate
    if [[ -z "${_PROJECT_PATH_TO_ACTIVATE:-}" ]] ; then
      echo "ERROR: Could not determine which project to activate."
      return 1
    fi
    project_path_to_activate="${_PROJECT_PATH_TO_ACTIVATE}"

  else
    if [[ -d "${_REPO_TOP}/apps/${project}" ]] ; then
      project_path_to_activate="apps/${project}"
    elif [[ -d "${_REPO_TOP}/libs/${project}" ]] ; then
      project_path_to_activate="libs/${project}"
    else
      echo "ERROR: unknown project '${project}'"
      return 1
    fi
  fi

  _activate_venv "${project_path_to_activate}"
  cd "${_REPO_TOP}/${project_path_to_activate}" || return
  _analyze_current_repo
}


# INPUT:
#   $_REPO_TOP - path to the top of the git repo
#   $1 - path relative to $_REPO_TOP containing a poetry project / requirements.txt file. (must be under $_REPO_TOP)
#   $2 - if 'refresh' then the venv will be destroyed and re-created if it already exists.
# OUTPUT:
#   @return return code: 0 on success, 1 on failure
#   @return VIRTUAL_ENV - envvar string - path to the activated virtual env
#
#  The path to the activated project will be put into $_REPO_TOP/.venv
function _activate_venv() {
  local project_dir="${1:-}" refresh="${2:-}"
  local venv_path was_venv_created=false

  if [[ -z "${PCO_VENV_DIR:-}" ]] || [[ -z "${_REPO_TOP:-}" ]] || [[ -z "${_REPO_METADATA_PATH:-}" ]] ; then
    echo "ERROR: PCO_VENV_DIR, _REPO_TOP, or _REPO_METADATA_PATH not defined"
    return 1
  fi

  if [[ ! -d "${_REPO_TOP}/${project_dir}" ]]; then
    echo "ERROR: Not a project directory: ${_REPO_TOP}/${project_dir}"
    return 1
  fi

  _deactivate_venv

  venv_path="${_REPO_METADATA_PATH}/${project_dir}/venv"
  if [[ -e $venv_path ]] && [[ $refresh == 'refresh' ]] ; then
    _destroy_venv_dir "${venv_path}"
  fi

  # Create virtualenv if it doesn't exist
  if [[ ! -d $venv_path ]]; then
    echo "$venv_path is not a directory, so creating the venv:"
    mkdir -p "${venv_path}"
    python3 -m venv "${venv_path}"
    was_venv_created=true
  fi

  echo -n "${project_dir}" > "${_REPO_METADATA_PATH}/active_project.txt"
  source "${venv_path}/bin/activate"
  if $was_venv_created ; then
    pip3 install --upgrade pip
  fi
}


# If already in a venv, deactivate it.
function _deactivate_venv() {
  [[ $(type -t deactivate) == "function" ]] && deactivate
  unset VIRTUAL_ENV
}


# Destroys a venv's directory, with some sanity checks.
#
# INPUT:
#   $1 - full path to a virtual env directory
# OUTPUT:
#   None
function _destroy_venv_dir() {
  local path="${1:-}"
  if [[ ! -d $path ]] ; then
    echo "ERROR: Cannot destroy venv, '${path}' does not exist."
    return 1
  fi
  if [[ ! -e "${path}/bin/activate" ]]; then
    echo "ERROR: Out of an abudance of caution, will not destroy venv, '${path}' does not appear to be a venv. (Missing bin/activate)"
    return 1
  fi
  rm -rf "${path}"
}


# Looks for a .venv file in the PWD or above, and activates it. Used when tmux
# creates a new pane in the current directory, which by default won't inherit
# the current virtualenv environment.
function _venv_auto_activate() {
  _analyze_current_repo --silent
  [[ -z "${_REPO_TOP:-}" ]] && return

  if [[ -n "${_REPO_METADATA_PATH:-}" ]] && [[ -n "${_REPO_ACTIVE_PROJECT_DIR:-}" ]]; then
    local venv_path="${_REPO_METADATA_PATH}/${_REPO_ACTIVE_PROJECT_DIR}/venv"
    if [[ -f "${venv_path}/bin/activate" ]] ; then
      source "${venv_path}/bin/activate"
    else
      echo "WARNING: Repo's active project does not have a valid venv: ${venv_path}"
    fi
  fi
}
