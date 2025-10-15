#!/bin/bash

set -e

# Parse arguments
VERSION=""
INCREMENT="patch"

while [[ $# -gt 0 ]]; do
    case $1 in
    --increment=*)
        INCREMENT="${1#*=}"
        shift
        ;;
    --increment)
        INCREMENT="$2"
        shift 2
        ;;
    *)
        VERSION="$1"
        shift
        ;;
    esac
done

# Validate increment option
if [[ ! "$INCREMENT" =~ ^(patch|minor|major)$ ]]; then
    echo "Error: --increment must be one of: patch, minor, major" >&2
    exit 1
fi

# Get latest tag
latest_tag=$(git tag --list 'v*' --sort=-v:refname | head -n 1)
echo "Latest tag: ${latest_tag:-None}"

# If VERSION is not provided, auto-increment version
if [ -z "${VERSION:-}" ]; then
    if [ -z "$latest_tag" ]; then
        echo "Error: No existing tags found. Please specify a version for the first tag." >&2
        exit 1
    fi

    latest_version=${latest_tag#v}

    # Extract MAJOR.MINOR.PATCH
    if [[ "$latest_version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        MAJOR="${BASH_REMATCH[1]}"
        MINOR="${BASH_REMATCH[2]}"
        PATCH="${BASH_REMATCH[3]}"

        # Increment version based on increment type
        case "$INCREMENT" in
        major)
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            ;;
        minor)
            MINOR=$((MINOR + 1))
            PATCH=0
            ;;
        patch)
            PATCH=$((PATCH + 1))
            ;;
        esac

        VERSION="$MAJOR.$MINOR.$PATCH"
        echo "Auto-incrementing $INCREMENT version to: $VERSION"
    else
        echo "Error: Latest tag $latest_tag is not in semantic version format" >&2
        exit 1
    fi
else
    # check version format vMAJOR.MINOR.PATCH
    if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: VERSION must be in format MAJOR.MINOR.PATCH, e.g. 1.2.3" >&2
        exit 1
    fi

    if [ -n "$latest_tag" ]; then
        latest_version=${latest_tag#v}
        earlier_version="$(printf '%s\n%s\n' "$latest_version" "$VERSION" | sort -V | head -n 1)"

        # If VERSION <= latest_version, abort
        if [ "$earlier_version" = "$VERSION" ]; then
            echo "Error: Specified version $VERSION is not later than the latest tag $latest_tag" >&2
            exit 1
        fi
    fi
fi

echo "Creating and pushing tag v$VERSION"
read -r -p "Are you sure you want to create and push this tag? (y/n) " confirm

if [ "$confirm" != "y" ]; then
    echo "Tagging aborted"
    exit 1
fi

git tag -a -m "Release v$VERSION" "v$VERSION"
git push origin "v$VERSION"
