# pco-devtools

This repo contains:
* Tools common to working with all PCO repos. This consists of Bash functions for cloning and navigating PCO git
  repos, and for managing the state of Python venvs used within those repos.
* Installation scripts to quickly get a new user set up with the tooling.

For full instructions on setting up a Linux environment, please consult
[PCO dev environment setup](https://docs.google.com/document/d/1Yp3Ixeh4FzvON2Sru6r1D9gBSvPGtn6WOhlYMpRMyhA/view).


## Installation

### Fedora Linux

With a fresh user that belongs to the `wheel` group (can `sudo` without a password), run the following:

```
curl --silent --show-error --location https://raw.githubusercontent.com/openshift-eng/pco-devtools/main/bootstrap.sh | bash
```

### MacOS

**Important!**: You must install Homebrew and update your bash before you begin the install process:

1. Install Homebrew (instructions from the [Homebrew website](https://brew.sh/)):

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

2. Install a modern Bash:

    brew install bash

3. Allow this bash to be a default shell (enter your password when prompted):

  (This 1-liner appends the path to the new bash to `/private/etc/shells`.)

    new_bash="$(brew --prefix)/bin/bash" ; ! grep -E "${new_bash}" /private/etc/shells >/dev/null && (echo "${new_bash}" | sudo tee -a /private/etc/shells)

4. Set your default shell to the new bash (enter your password when prompted):

    chsh -s "$(brew --prefix)/bin/bash"

5. Use the new Bash:

   Either restart your terminal, or run `exec "$(brew --prefix)/bin/bash"`

6. Begin the install process:

```
curl --silent --show-error --location https://raw.githubusercontent.com/openshift-eng/pco-devtools/main/bootstrap.sh | bash
```


## About Python "Projects"

A Project is either a directory containing a `pyproject.toml` file or `requirements.txt` file. Each Project has
its own independent venv.

Some venv and intra-repo navigation commands target a Project, and these are referred to by the Project's name.
A Project's name depends on its location within the repo:

- A Project defined by a `requirements.txt` file at the top of the repo has an empty name. The navigation
  commands implicitly auto-target this Project.
- A repo with multiple projects (e.g. `openshift-eng/infra-toolbox`) refers to a project by the name of the directory
  containing the Project.  e.g. The Project within `/apps/aws-toolkit` is referred to as `aws-toolkit`, and the
  Project within `/libs/dpp-github-config` is referred to as `dpp-github-config`.

### Active Project

Activating a venv for a Project marks it as the "Active Project".  Each repo stores its own Active Project
independent of other repos.

Changing directories into a repo will automatically re-activate the Active Project's venv (if it exists).


## Usage

### Repo management

#### `clone_repo.sh [--upstream-only] REPO_NAME [TARGET_DIR_NAME]`

Clones a PCO-owned repo and configures it:

1. Clones `github.com/<your_github_username>/REPO_NAME` into `PCO_REPO_DIR/TARGETDIR_NAME`. (`TARGETDIR_NAME` defaults
   to `REPO_NAME`). If `--upstream-only` is specified, it clones from `github.com/openshift-eng/REPO_NAME` and
   does not perform further configuration.
2. Adds the git remote `upstream`: `github.com/openshift-eng/REPO_NAME`
3. Installs the repo's pre-commit hook, if it has one.

This script is located at the top of this repo.

It uses the `gh` underneath the hood, so you must have previously authorized `gh` with `gh auth login`.


#### `repo REPO_NAME`

Change directory to `$PCO_REPO_DIR/REPO_NAME` and auto-activate the venv (if there is one).


#### `allbranches`
List all repos under `$PCO_REPO_DIR`, and what git branch they're checked out to.


### Venv management & intra-repo navigation

These commands are expected to be called from within a repo.

#### `cdtop`

Change directory to the top of the repo.


#### `cdpylibs`
Change directory to the current venvs's directory of installed `site-packages`. This is useful for inspecting the
source code of installed pip dependencies.


#### `cdd [PROJECT]`

Change directory to `PROJECT`. The current venv is _not_ modified.

Use `[TAB]` to autocomplete `PROJECT`. e.g. `cdd aws-to[TAB]` --> `cdd aws-toolkit`.

For repos with only a single Project (in the top directory), the Project name is implicit.


#### `venv on`

Activates a venv for the nearest Project.

1. Find the nearest Project, found by searching upwards from the current directory, and mark it as the Active Project.
2. Activate the Project's venv (creating it if necessary).


#### `venv off`

Deactivate the current venv (if there is one), and clear the "Active Project".


#### `venv destroy`

Same as `venv off` except the venv's directory will be deleted.


#### `venv go [PROJECT]`

Change directory to PROJECT's directory and activate the venv. (Same as `cdd [PROJECT] ; venv on`)

Similar to `cdd [PROJECT]`, autocomplete on PROJECT is supported.


### Special shortcuts

#### `cdat`

In a `infra-toolbox` repo, this is a shortcut to change directory into Atlas's main source code.

Shortcut for `cdd atlas ; cd atlas`


#### `cdsup`

In a `infra-toolbox` repo, this is a shortcut to change directory into `/apps/support-toolkit` where most support
tasks are performed.

Shortcut for `venv go support-toolkit`
