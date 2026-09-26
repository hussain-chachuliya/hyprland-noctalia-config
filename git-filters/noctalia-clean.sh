#!/usr/bin/env bash
#
# git "clean" filter for hypr/noctalia.lua
#
# Noctalia rewrites the theme colors at the top of hypr/noctalia.lua every
# time the wallpaper changes. Those values are machine-local noise, so this
# filter normalizes them to rgb(000000) *before* git hashes the file.
#
# Result: the file stays fully tracked (real edits to lines 11+ still show up
# in git status), but wallpaper changes never appear as modifications and
# never land in a commit.
#
# Setup, once per clone (the attribute itself is in .gitattributes). Run from
# the repo root so the shell expands $PWD correctly, and keep the double quotes:
#   git config filter.noctalia-colors.clean    "$PWD/git-filters/noctalia-clean.sh"
#   git config filter.noctalia-colors.smudge    cat
#   git config filter.noctalia-colors.required true
# Or just use the absolute path, e.g. /home/hussain/.config/git-filters/noctalia-clean.sh
#
# `required = true` makes `git add` fail loudly instead of silently committing
# raw colors if the script is missing on some other machine.
#
# The `smudge cat` line is NOT optional: it is an identity filter for the
# checkout direction, and without it `required = true` makes git die the moment
# it has to write hypr/noctalia.lua (clone/checkout/reset/rebase) with:
#   fatal: hypr/noctalia.lua: smudge filter noctalia-colors failed
#
# Only lines of the form `local <name> = "rgb(XXXXXX)"` are touched; anything
# else passes through byte for byte. The transformation is idempotent, so
# rgb(000000) stays rgb(000000).
#
set -euo pipefail

exec sed -E 's/^(local [a-z_]+ = "rgb\()[0-9a-fA-F]{6}(\)")$/\1000000\2/'
