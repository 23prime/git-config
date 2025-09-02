#!/bin/bash

set -eu

git switch -c "$1"
git push -u origin "$1"
