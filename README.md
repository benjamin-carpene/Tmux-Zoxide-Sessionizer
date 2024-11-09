# Description

TZ is a simple and stupid glue script to make a Tmux-Zoxide sessionizer.
The goal is to use the power of zoxide to create tmux sessions in one line and no time.
This script's aim is to keep it simple, with as few dependencies as possible, in bash, as it should be.
No useless packages required, no additional libraries and package managers, just tmux [ and zoxide :) ].

# Usage

## Synopsis

`tz [zoxide_dir] | [--help | -h]`
- zoxide_dir: the directory searched for in zoxide
    - If it is set, tz will search for this directory in zoxide and open it as a tmux session
    - If it is unset, you will be prompted interactively to select a zoxide directory
- --help | -h: Shows this help message

## Example

`tz feature-a`: Create / connect to a session attached to 'feature-a' directory.
`tz`: Asks for the user to select a directory to create / connect to a session.

# Installation

1. Clone this repo : `git clone https://github.com/benjamin-carpene/tz.git`
2. Use the installation script : `cd tz && ./install.sh`
