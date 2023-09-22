#!/usr/bin/env bash
# Functions to add color messages to shell scripts.

# Global vars
declare -g -A COLORS=(
)
# Are we running in a terminal?
if [[ -t 1 ]] ; then
    # Is `tput` available?
    if type tput > /dev/null ; then
        COLORS=(
            [reset]=$(tput sgr0)
            [underline]=$(tput sgr 0 1)
            [light]=$(tput bold)

            [black]=$(tput setaf 0)
            [light_black]=$(tput bold; tput setaf 0)

            [red]=$(tput setaf 1)
            [light_red]=$(tput bold; tput setaf 1)

            [green]=$(tput setaf 2)
            [light_green]=$(tput bold; tput setaf 2)

            [yellow]=$(tput setaf 3)
            [light_yellow]=$(tput bold; tput setaf 3)

            [blue]=$(tput setaf 4)
            [light_blue]=$(tput bold; tput setaf 4)

            [magenta]=$(tput setaf 5)
            [light_magenta]=$(tput bold; tput setaf 5)

            [cyan]=$(tput setaf 6)
            [light_cyan]=$(tput bold; tput setaf 6)

            [white]=$(tput setaf 7)
            [light_white]=$(tput bold; tput setaf 7)
            [gray]=$(tput setaf 7)
        )
    else
        COLORS=(
            [reset]="$(printf "\033[0m")"
            [underline]=""
            [light]=""

            [black]="$(printf "\033[0;30m")"
            [light_black]="$(printf "\033[1;30m")"

            [red]="$(printf "\033[0;31m")"
            [light_red]="$(printf "\033[1;31m")"

            [green]="$(printf "\033[0;32m")"
            [light_green]="$(printf "\033[1;32m")"

            [yellow]="$(printf "\033[0;33m")"
            [light_yellow]="$(printf "\033[1;33m")"

            [blue]="$(printf "\033[0;34m")"
            [light_blue]="$(printf "\033[1;34m")"

            [magenta]="$(printf "\033[0;35m")"
            [light_magenta]="$(printf "\033[1;35m")"

            [cyan]="$(printf "\033[0;36m")"
            [light_cyan]="$(printf "\033[1;36m")"

            [white]="$(printf "\033[0;37m")"
            [light_white]="$(printf "\033[1;37m")"
            [gray]="$(printf "\033[0;37m")"
        )
    fi
else
    # If we're not running in a terminal, prevent scripts that reference this array from erroring out with `set -o
    # nounset` enabled.
    # shellcheck disable=SC2034
    COLORS=(
        [reset]=""
        [underline]=""
        [light]=""

        [black]=""
        [light_black]=""

        [red]=""
        [light_red]=""

        [green]=""
        [light_green]=""

        [yellow]=""
        [light_yellow]=""

        [blue]=""
        [light_blue]=""

        [magenta]=""
        [light_magenta]=""

        [cyan]=""
        [light_cyan]=""

        [white]=""
        [light_white]=""
        [gray]=""
    )
fi
