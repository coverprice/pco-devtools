#!/bin/bash

set -o errexit -o nounset -o pipefail
INSTALL_ALL_HERE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

"${INSTALL_ALL_HERE}/install_editor_tools.sh"
"${INSTALL_ALL_HERE}/install_tools.sh"
"${INSTALL_ALL_HERE}/install_python_tools.sh"
"${INSTALL_ALL_HERE}/install_navtools.sh"
