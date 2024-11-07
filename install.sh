#!/bin/env bash

if [ -n $HOME ]; then
    local_bin_dir="$HOME/.local/bin"
    mkdir -p "$local_bin_dir"
    cp tz.sh "$local_bin_dir/tz"

    echo "tz has been installed in $local_bin_dir"

    if [[ "$PATH" != *"$local_bin_dir"* ]]; then
        echo "You may not have $local_bin_dir in your PATH variable, which is necessary for tz."
        echo "Type \`echo \"PATH=\$PATH:$local_bin_dir\" > $HOME/.bashrc\` in order to add it to your path"
    fi
else
    echo "User has no HOME folder"
    exit 1
fi
