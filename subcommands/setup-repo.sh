#!/bin/bash

set -eu

# Parse options
remote_flag=false
while getopts "r-:" opt; do
    case $opt in
    r)
        remote_flag=true
        ;;
    -)
        case "${OPTARG}" in
        remote)
            remote_flag=true
            ;;
        *)
            echo "Unknown option --${OPTARG}" >&2
            exit 1
            ;;
        esac
        ;;
    *)
        echo "Usage: $0 [-r|--remote] <repo> [owner]" >&2
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

# Check that $1 (repo) is provided
if [ -z "${1:-}" ]; then
    echo "Usage: $0 [-r|--remote] <repo> [owner]" >&2
    exit 1
fi

repo=$1
owner=${2:-}

# Abort if directory with the same name as $repo already exists
if [ -d "$repo" ]; then
    echo "Error: Directory '$repo' already exists." >&2
    exit 1
fi

# Create local repository and initialize
mkdir -p "$repo"
cd "$repo"

git init
git initial-commit

# Create remote repository on GitHub if --remote flag is specified
if [ "$remote_flag" = true ]; then
    if [ -n "$owner" ]; then
        remote_repo="$owner/$repo"
    else
        remote_repo="$repo"
    fi

    echo "Creating remote repository on GitHub..."
    gh repo create "$remote_repo" --private --source=. --remote=origin --push
else
    echo "Local repository created successfully."
    echo "To create a remote repository later, use: gh repo create --private --source=. --remote=origin --push"
fi
