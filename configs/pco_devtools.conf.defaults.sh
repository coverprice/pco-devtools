export PCO_BASE_DIR=~/dev
export PCO_REPO_DIR="${PCO_BASE_DIR}/repos"
export PCO_VENV_DIR="${PCO_BASE_DIR}/venvs"

export REQUESTS_CA_BUNDLE="${REQUESTS_CA_BUNDLE:-/etc/pki/tls/certs/ca-bundle.crt}"


# This lets gpg-agent work correctly within tmux
# shellcheck disable=SC2155
export GPG_TTY="$(tty)"

# Disable Bash autocomplete on files/dirs with these extensions
export FIGNORE=".o:__pycache__:.pyc"

# export PROMPT_COMMAND=prompt_update
