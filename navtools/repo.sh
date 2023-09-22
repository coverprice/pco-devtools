#!/usr/bin/env bash
#cd to another repo under PCO_REPO_DIR
#
# Usage:
#   repo REPONAME
# Example:
#   repo infra-toolbox
#
# Inputs:
#     PCO_REPO_DIR
# Outputs:
#     None
function repo() {
  local - reponame="${1:-}" repodir
  set -o errexit -o nounset
  if [[ -z $reponame ]] ; then
    echo "You must specify a repo name, under ${PCO_REPO_DIR}"
    return
  fi
  repodir="${PCO_REPO_DIR}/${reponame}"
  if [[ ! -d $repodir ]] ; then
    echo "Error: Directory does not exist: '${repodir}'"
    return
  fi
  if [[ ! -d "${repodir}/.git" ]] ; then
    echo "Error: Directory does not appear to be a git repository. '${repodir}'"
    return
  fi
  cd "${repodir}"

  # Refresh _REPO_TOP.
  _analyze_current_repo
  if [[ -n "${_REPO_TOP:-}" ]] && $_REPO_IS_MONOREPO ; then
    export CDPATH=".:${repodir}:${repodir}/apps/atlas/atlas"
  else
    export CDPATH=".:${repodir}"
  fi

  # Attempt to activate a venv
  set +o errexit
  _venv_on
  set -o errexit
  if [[ -n "${_REPO_TOP:-}" ]] && [[ -n "${_REPO_ACTIVE_PROJECT_DIR:-}" ]] ; then
    cd "${_REPO_TOP}/${_REPO_ACTIVE_PROJECT_DIR}"
  fi
}


function _repo_autocomplete() {
  # This autocompletes 'repo <some-repo>'
  # See load.sh for how the function is installed.
  # shellcheck disable=SC2034
  local - command_name="${1:-}" word_being_completed="${2:-}" word_preceding="${3:-}" repo_options
  set -o errexit -o nounset
  unset COMPREPLY

  # Find the list of dirs under PCO_REPO_DIR that contain git repos
  mapfile -t repo_options < <(find "${PCO_REPO_DIR}" -maxdepth 2 -mindepth 2 -name .git -type d -printf "%h\n" | sed -e 's#^.*/##')
  [[ ! -v repo_options ]] && return
  mapfile -t COMPREPLY < <(compgen -W "${repo_options[*]}" "${word_being_completed}")
}


# Print out a list of all repos, along with the branch they're currently checked out to.
#
# Usage:
#   allbranches
#
# Inputs:
#     PCO_REPO_DIR
# Outputs:
#     None
function allbranches() {
  local - dir_name
  set -o errexit -o nounset
  for git_dir in "${PCO_REPO_DIR}"/*/.git ; do
    dir_name="$(basename "$(dirname "$(dirname "${git_dir}")")")"
    printf "%s: %s\n" "${dir_name}" "$(git --git-dir "${git_dir}" rev-parse --abbrev-ref HEAD)"
  done
}
