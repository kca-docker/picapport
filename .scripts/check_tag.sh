#!/usr/bin/env sh

if GIT_DIR=./.git git rev-parse "$1^{tag}" >/dev/null 2>&1
then
    echo "Found tag"
else
    echo "Tag not found"
fi