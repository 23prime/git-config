#!/bin/bash

set -eu

link_path="${1:-$HOME/.config/git/config.d/alias.conf}"

rm -f "$link_path"

git config --global --unset include.path "$link_path"

echo "Done!"
