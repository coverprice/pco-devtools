# ==========================
# Generate the Bash prompt
# ==========================


# Inputs:
#  $_REPO_TOP - string - path to git top directory (from _analyze_current_repo)
# Outputs:
#  _ACTIVE_PROJECT_PROJECT str - string to display in the prompt that shows the currently active project
function _active_project_prompt() {
  local project_name

  _ACTIVE_PROJECT_PROMPT=
  [[ -z "${VIRTUAL_ENV:-}" ]] && return
  [[ -z "${_REPO_METADATA_PATH:-}" ]] && return

  if [[ -z "${_REPO_ACTIVE_PROJECT_DIR:-}" ]]; then
    _ACTIVE_PROJECT_PROMPT="$(printf "%s[No active project]%s " "${COLORS[red]}" "${COLORS[reset]}")"
    return
  elif [[ "${_REPO_ACTIVE_PROJECT_DIR:-}" == "." ]] ; then
    project_name="repo-wide venv"
  else
    project_name="$(basename "${_REPO_ACTIVE_PROJECT_DIR}")"
  fi

  # shellcheck disable=SC2155
  local venv_path="$(readlink -f "${_REPO_METADATA_PATH}/${_REPO_ACTIVE_PROJECT_DIR}/venv")"
  if [[ ! -d $venv_path ]]; then
    _ACTIVE_PROJECT_PROMPT="$(printf "%s[%s]%s " "${COLORS[red]}" "${project_name}" "${COLORS[reset]}")"
    return
  fi

  if [[ $VIRTUAL_ENV != "${venv_path}" ]]; then
    _ACTIVE_PROJECT_PROMPT="$(printf "%s[%s XXX different venv XXX]%s " "${COLORS[red]}" "${project_name}" "${COLORS[reset]}")"
    return
  fi

  # shellcheck disable=SC2034
  _ACTIVE_PROJECT_PROMPT="$(printf "%s[%s]%s " "${COLORS[reset]}${COLORS[cyan]}" "${project_name}" "${COLORS[reset]}")"
}


function pco_prompt_update() {
  local branch git_top repo_name git_branch_prompt
  _ACTIVE_PROJECT_PROMPT=
  _analyze_current_repo --silent
  if [[ -n "${_REPO_TOP:-}" ]] ; then
    repo_name="$(basename "$(dirname "${_REPO_TOP}")")"
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    git_branch_prompt="$(printf "%s[%s%s %s%s] " "${COLORS[light_white]}" "${COLORS[reset]}" "${repo_name}" "${COLORS[light_white]}" "${branch}")"
    _active_project_prompt "${_REPO_TOP}"
  fi
  PS1="${git_branch_prompt}${_ACTIVE_PROJECT_PROMPT}${COLORS[reset]}${COLORS[green]}[${COLORS[gray]}\\u ${COLORS[green]}\\w]${COLORS[reset]}\\$ "
}
