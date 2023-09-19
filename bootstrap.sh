#!/usr/bin/env bash
# Clones this repo. Intended to be run as part of a "curl [this file's Github URL] | bash" pipeline.

set -o errexit -o nounset -o pipefail -o xtrace
mkdir -p ~/dev/repos
git clone https://github.com/openshift-eng/pco-devtools.git ~/dev/repos/
~/dev/repos/pco-devtools/install_all.sh
