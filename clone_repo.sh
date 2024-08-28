#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"


function usage() {
  cat <<EOF
Clones a PCO-owned repo from openshift-env and configures it.


Usage:  ${0} [-u] [-y] REPO_NAME [TARGET_DIR_NAME]

   -u:  upstream only            Only clone the openshift-eng/REPO_NAME, do not try to clone your fork of it.
   -y:  yes                      Answer yes to all questions


Examples:
  Clone <your_github_username>/infra-toolbox into ~/dev/repos/my-infra-toolbox/ :
      ${0} infra-toolbox my-infra-toolbox

  Clone <your_github_username>/infra-toolbox into ~/dev/repos/infra-toolbox/ :
      ${0} infra-toolbox


1. Clones 'github.com/<your_github_username>/REPO_NAME' into '\$PCO_REPO_DIR/TARGET_DIR_NAME'.

   - 'TARGET_DIR_NAME' defaults to 'REPO_NAME'.
   - If '-u' is specified, it clones from 'github.com/openshift-eng/REPO_NAME' and does not perform
     further configuration.
   - The clone is performed with the 'gh repo clone' tool, which will automatically set the 'origin' and 'upstream'
     remotes.

2. Installs the repo's pre-commit hook, if it has one.
EOF
}


# Input: "$@"
# Output
#   UPSTREAM_ONLY - boolean - If the user requested only to clone the upstream repo in openshift-eng
#   ALWAYS_YES - boolean - Always answer yes to any prompts
#   REPO_NAME - string - the repo name to clone (e.g. `infra-toolbox`)
#   TARGET_DIR - string - Absolute path to the target directory to clone to
function parse_args {
  local opt OPTIND

  # Defaults
  UPSTREAM_ONLY=false
  ALWAYS_YES=false

  while getopts "huy" opt; do
    case "${opt}" in
      u)
        UPSTREAM_ONLY=true
        ;;
      y)
        ALWAYS_YES=true
        ;;
      h|\?)
        usage
        exit 0
        ;;
      :)
        echo "Invalid option: ${OPTARG} requires an argument"
        usage
        exit 1
        ;;
     esac
  done
  # Remove any script params that getopts has processed.
  shift $((OPTIND-1))

  REPO_NAME="${1:-}"
  TARGET_DIR_NAME="${2:-${REPO_NAME}}"

  if [[ -z $REPO_NAME ]] ; then
    usage
    exit 0
  fi
  if [[ ! $REPO_NAME =~ ^[-.a-zA-Z0-9]+$ ]] ; then
    echo "Error: REPO_NAME contains invalid characters."
    echo "   (Hint: should just be the repo's name, not its URL, e.g. infra-toolbox)"
    usage
    exit 1
  fi
  if [[ ! $TARGET_DIR_NAME =~ ^[-.a-zA-Z0-9]+$ ]] ; then
    echo "Error: TARGET_DIR_NAME contains invalid characters."
    echo "   (Hint: should just be the target directory's, e.g. 'my-infra-toolbox')"
    usage
    exit 1
  fi
  if [[ -z "${PCO_REPO_DIR:-}" ]] ; then
    echo "Error: PCO_REPO_HOME not configured. Please consult the README.md: ${HERE}/README.md"
    usage
    exit 1
  fi

  TARGET_DIR="${PCO_REPO_DIR}/${TARGET_DIR_NAME}"
  if [[ -d $TARGET_DIR ]] ; then 
    echo "Error: Target directory already exists: ${TARGET_DIR}"
    exit 1
  fi
}


# Input: none
# Output: GITHUB_USERNAME - string - the user's Github login name, extracted from `gh auth status`
function get_github_username {
  local gh_auth_output regex="Logged in to github.com account ([-.a-zA-Z0-9]+) "
  gh_auth_output="$(gh auth status --hostname github.com)"
  if [[ ! $gh_auth_output =~ $regex ]] ; then
     echo "Error: You do not appear to be logged into github.com with the 'gh' tool."
     echo "Hint: run the following to login:"
     echo "      gh auth login --hostname github.com"
     exit 1
  fi
  GITHUB_USERNAME="${BASH_REMATCH[1]}"
}


function repo_exists {
  local repo_org_name="${1}"
  gh repo view "${repo_org_name}" --json name --jq .name >/dev/null
}


function clone_repo {
  local - upstream_only="${1}" github_username="${2}" repo_name="${3}" target_dir="${4}" always_yes="${5}"
  local forked_repo="${github_username}/${repo_name}"
  local upstream_repo="openshift-eng/${repo_name}"

  if ! repo_exists "${upstream_repo}" ; then
    echo "Error: Upstream repo '${upstream_repo}' does not exist (or you are not authorized to view it)"
    exit 1
  fi
  if $upstream_only ; then
    set -o xtrace
    gh repo clone "${upstream_repo}" "${target_dir}"
    set +o xtrace
    return
  fi

  # Clone the user's fork
  if ! repo_exists "${forked_repo}" ; then
    echo "You do not appear to have a fork of '${upstream_repo}'."
    if ! $always_yes ; then
      read -p "Do you want to fork & clone '${upstream_repo}'? [y/n] " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting."
        exit 1
      fi
    fi
    echo "Forking ${upstream_repo}"
    # Note: `gh repo fork` has a `--clone` option, but this does not allow us to specify the target dir.
    set -o xtrace
    gh repo fork "${upstream_repo}"
    set +o xtrace
  fi

  echo "Cloning ${forked_repo}"
  set -o xtrace
  gh repo clone "${forked_repo}" "${target_dir}"
  set +o xtrace
}


function setup_repo {
  local git_repo_top="${1}"
  if [[ -f "${git_repo_top}/tools/build/pre-commit" ]]; then
    echo "Installing pre-commit hook."
    cd "${git_repo_top}/.git/hooks"
    ln -s "../../tools/build/pre-commit" pre-commit
  fi
  cd "${git_repo_top}"
}


function main {
  parse_args "$@"
  get_github_username
  echo "Using currently logged in Github user: ${GITHUB_USERNAME}"
  clone_repo "${UPSTREAM_ONLY}" "${GITHUB_USERNAME}" "${REPO_NAME}" "${TARGET_DIR}" "${ALWAYS_YES}"
  setup_repo "${TARGET_DIR}"
  echo "Repo ${REPO_NAME} successfully cloned into ${TARGET_DIR}"
}


main "$@"
