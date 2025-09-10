#!/bin/bash

set -eu

print_usage() {
    cat <<'EOF'
Usage: git repo-ls [options] [ROOT]

Recursively lists Git repositories under ROOT (default: .).
A repository is detected if:
  - a ".git" entry exists (directory or file), or
  - a bare repository directory ending with ".git" exists.

Options:
  -a, --abs              Print absolute paths.
  -d, --depth N          Limit search to repositories at most N directory levels below ROOT
                         (0 = ROOT itself only; 1 = children; 2 = grandchildren; ...).
  -h, --help             Show this help and exit.

Examples:
  git repo-ls
  git repo-ls -a -d 1 ~/projects
EOF
}

ABS_PATH=0
DEPTH=""
ROOT=""

# Parse arguments (options may appear before or after ROOT)
while [ $# -gt 0 ]; do
    case "$1" in
    -a | --abs | --absolute | --full)
        ABS_PATH=1
        ;;
    -d | --depth)
        shift
        if [ $# -eq 0 ]; then
            printf "Error: --depth requires a value.\n" >&2
            exit 2
        fi
        DEPTH="$1"
        ;;
    --depth=*)
        DEPTH="${1#*=}"
        ;;
    -h | --help)
        print_usage
        exit 0
        ;;
    --)
        shift
        if [ $# -gt 0 ]; then
            if [ -n "$ROOT" ]; then
                printf "Error: Multiple ROOT paths specified: %s %s\n" "$ROOT" "$1" >&2
                exit 2
            fi
            ROOT="$1"
            shift
        fi
        if [ $# -gt 0 ]; then
            printf "Error: Unexpected extra argument: %s\n" "$1" >&2
            exit 2
        fi
        break
        ;;
    -*)
        printf "Unknown option: %s\n" "$1" >&2
        exit 2
        ;;
    *)
        if [ -n "$ROOT" ]; then
            printf "Error: Multiple ROOT paths specified: %s %s\n" "$ROOT" "$1" >&2
            exit 2
        fi
        ROOT="$1"
        ;;
    esac
    shift
done

ROOT=${ROOT:-.}

# Validate depth if specified (must be non-negative integer)
if [ -n "$DEPTH" ]; then
    case "$DEPTH" in
    '' | *[!0-9]*)
        printf "Error: depth must be a non-negative integer: %s\n" "$DEPTH" >&2
        exit 2
        ;;
    *) ;;
    esac
fi

if [ ! -d "$ROOT" ]; then
    printf "Error: ROOT directory not found: %s\n" "$ROOT" >&2
    exit 1
fi

# Build portable maxdepth clause if supported
MAXDEPTH_CLAUSE=()
if [ -n "$DEPTH" ]; then
    if find "$ROOT" -maxdepth 0 -print >/dev/null 2>&1; then
        # '+1' because '.git' lives one level under a non-bare repo directory
        md=$((DEPTH + 1))
        MAXDEPTH_CLAUSE=(-maxdepth "$md")
    else
        printf "Warning: 'find' does not support -maxdepth; ignoring -d.\n" >&2
    fi
fi

# Find candidate repositories and print validated roots
{
    # Normal repos and submodules: .git directory
    find "$ROOT" "${MAXDEPTH_CLAUSE[@]}" -type d -name .git -prune -print
    # Worktrees: .git file
    find "$ROOT" "${MAXDEPTH_CLAUSE[@]}" -type f -name .git -print
    # Bare repositories typically end with ".git" (avoid matching the above .git entries)
    find "$ROOT" "${MAXDEPTH_CLAUSE[@]}" -type d -name '*.git' ! -path '*/.git' -prune -print
} 2>/dev/null |
    while IFS= read -r path; do
        base=$(basename "$path")
        if [ "$base" = ".git" ]; then
            repo=$(dirname "$path")
        else
            repo="$path"
        fi

        # Validate using git to avoid false positives
        if git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
            if [ "$ABS_PATH" -eq 1 ]; then
                (
                    cd "$repo"
                    pwd -P
                )
            else
                printf "%s\n" "$repo"
            fi
        fi
    done |
    sort -u
