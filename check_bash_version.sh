#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

# MacOS by default has a very old bash, it must be updated before any of the other scripts can be run.
if [[ "${BASH_VERSINFO[0]}" -lt 5 ]]; then
  echo "ERROR! Your version of bash is too old! Please follow the instructions in the README to update it,"
  echo "then re-run this script."
  exit 1
fi

if [[ ! $SHELL =~ bash$ ]]; then
  echo "ERROR! Your default shell is not Bash! These tools rely on your default shell being Bash to function."
  echo "Consult the README for instructions on permanently updating your shell to Bash."
  exit 1
fi

