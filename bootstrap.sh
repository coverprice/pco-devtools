#!/usr/bin/env bash
# Clones this repo. Intended to be run as part of a "curl [this file's Github URL] | bash" pipeline.

set -o errexit -o nounset -o pipefail -o xtrace

if [[ "${BASH_VERSINFO[0]}" -lt 5 ]]; then
  echo "ERROR! Your version of bash is too old! Please follow the instructions in the README to update it,"
  echo "then re-run this script."
  exit 1
fi

mkdir -p ~/dev/repos
git clone https://github.com/openshift-eng/pco-devtools.git ~/dev/repos/pco-devtools
~/dev/repos/pco-devtools/install_all.sh
