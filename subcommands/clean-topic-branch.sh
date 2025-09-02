#!/bin/bash

set -eu

current_branch=$(git-current-branch)

if [[ "$current_branch" == "main" ]]; then
    echo "Error: current branch is 'main'."
    exit 1
fi

git switch main
git pull
git branch -d "$current_branch"
git fetch --prune
