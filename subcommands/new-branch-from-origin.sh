#!/bin/bash

set -eu

git switch -c "$1" origin/"$1"
