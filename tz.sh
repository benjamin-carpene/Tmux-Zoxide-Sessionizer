#!/bin/env bash

# Utility print functions
RED=""
GREEN=""
RESET=""
color_number=$(tput colors)
# Set colors if we are linked to a tty and the terminal is color compatible
if [ -t 1 ] && [ "$color_number" -ge 8 ]; then
    RED="\e[31m"
    GREEN="\e[32m"
    RESET="\e[0m"
fi

function print_err() {
    # Prints in red args to stderr
    echo -e "${RED}${@}${RESET}" >&2
}

function print_out() {
    echo -e "${GREEN}${@}${RESET}"
}

# Script functions
function usage() {
    print_out "TZ USAGE"
    print_out

    print_out "SYNOPSIS"
    print_out "\ttz [zoxide_dir] | [--help | -h]"
    print_out "\t\tzoxide_dir: the directory searched for in zoxide"
    print_out "\t\t\tIf it is set, tz will search for this directory in zoxide and open it as a tmux session"
    print_out "\t\t\tIf it is unset, you will be prompted interactively to select a zoxide directory"
    print_out "\t\t--help | -h: Shows this help message"
    print_out

    print_out "DESCRIPTION"
    print_out "\tA simple and stupid glue script to make a Tmux-Zoxide sessionizer."
    print_out "\tThe goal is to use the power of zoxide to create tmux sessions in one line and no time."
    print_out "\tThis script's aim is to keep it simple, with as few dependencies as possible, in bash, as it should be."
    print_out "\tNo useless packages required, no additional libraries and package managers, just tmux [ and zoxide :) ]."
    print_out

    print_out "EXAMPLES"
    print_out "\ttz feature-a: Create / connect to a session attached to 'feature-a' directory."
    print_out "\ttz: Asks for the user to select a directory to create / connect to a session."
    print_out
}

function check_dependencies() {
    # All the dependencies of this script (all non builtins)
    readonly DEPS=(
        tmux
        zoxide
        fzf
        basename
        realpath
        sleep
        getopt
    )

    # Checks that the dependencies are met
    for dep in "${DEPS[@]}"; do
        type "$dep" &>/dev/null || {
            print_err "Dependency '$dep' is required but cant be found in your PATH variable"
            return 1
        }
    done
    return 0
}

function parse_args() {
    # Only help function for now
    SHORTOPTS="h"
    LONGOPTS="help"

    # Parsing options
    PARSED=$(getopt --options=$SHORTOPTS --longoptions=$LONGOPTS --name "$0" -- "$@")
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
    eval set -- "$PARSED"

    # Process options
    while true; do
        case "$1" in
            -h|--help)
                usage
                shift
                exit 0
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Unexpected option: $1"
                exit 1
                ;;
        esac
    done

    # Remaining arguments are used as search terms
    search="$@"

    if [ -n "$search" ]; then
        tz_mode="STATIC"
    else
        tz_mode="INTERACTIVE"
    fi
}

function tmux_handle_connect() {
    # Create a session if necessary
    if ! tmux has-session -t "$dir_basename" 2>/dev/null; then
        tmux new-session -d -s "$dir_basename" -c "$dir_path"
    fi

    # Attach / switch to the given session
    if [ -z "$TMUX" ]; then
        tmux attach-session -t "$dir_basename"
    else
        tmux switch-client -t "$dir_basename"
    fi
}

function handle_tz_static() {
    dir_path=$(zoxide query "$search" 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$dir_path" ]; then
        print_err "Zoxide didnt find anything matching your inputs"
        return 1
    fi

    dir_basename=$(basename "$dir_path")
    search_basename=$(basename "$search")

    # if is an exact match
    if [ "$dir_basename" = "$search_basename" ]; then
        tmux_handle_connect
    else
        print_err "There is no strictly equal directory in zoxide. The nearest directory name is the following : $dir_basename (fullpath: $dir_path)"
        return 1
    fi
}

function handle_tz_interactive() {
    dir_path=$(zoxide query -i)
    if [ $? -ne 0 ] || [ -z "$dir_path" ]; then
        print_err "Zoxide didnt find anything matching your inputs"
        return 1
    fi

    dir_basename=$(basename "$dir_path")
    tmux_handle_connect
}

# Script's data
search=""
tz_mode=""
dir_path=""
dir_basename=""

# Parse the arguments
parse_args "$@"

# Handles the connections to tmux
case "$tz_mode" in
    "STATIC")
        check_dependencies || exit $?
        handle_tz_static
        ;;
    "INTERACTIVE")
        check_dependencies || exit $?
        handle_tz_interactive
        ;;
    *)
        print_err "tz_mode unrecognized";
        exit 1
        ;;
esac

# Exits previous errcode
exit $?
