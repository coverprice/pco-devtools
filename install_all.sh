#!/bin/bash

set -o errexit -o nounset -o pipefail
INSTALL_ALL_HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

source "${INSTALL_ALL_HERE}/install_editor_tools.sh"
source "${INSTALL_ALL_HERE}/install_devtools.sh"
source "${INSTALL_ALL_HERE}/install_python_tools.sh"
source "${INSTALL_ALL_HERE}/install_navtools.sh"
