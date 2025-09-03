#!/bin/bash

set -eu

git switch -c feature/"$1"
git push -u origin feature/"$1"
