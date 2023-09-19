function _navtools_usage() {
  cat <<"EOF"
Usage:
  repo REPONAME               Change directories to the repo and activate the most recently activated venv there.

  venv [-h | --help | help | info | usage]  Display this help
  venv go [PROJECT]         Change directories and venvs to the given PROJECT (which is auto-completeable)
                                 In infra-toolbox, 'PROJECT' refers to an app or library.
                                 In other repos, this is not used and is equivalent to `venv on`.
  venv off                    Deactivate the current venv
  venv destroy                Deactivate and delete the current venv

  cdd PROJECT                 [Infra-toolbox repos only] cd to the given PROJECT (which is auto-completeable)
  cdat                        [Infra-toolbox repos only] cd to the atlas development directory
  cdsup                       [Infra-toolbox repos only] cd to the support-toolkit & activate the venv.
  cdtop                       cd to top of the current git repo
  cdpylibs                    cd to the venv's lib/site-packages dir
EOF
}
