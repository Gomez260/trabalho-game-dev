#!/bin/sh
printf '\033c\033]0;%s\a' TrabalhoGameDev
base_path="$(dirname "$(realpath "$0")")"
"$base_path/TrabalhoGameDev.x86_64" "$@"
