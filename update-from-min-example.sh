#!/bin/bash

set -x
set -e

wanted_files=("wrap.fnl" "error-mode.fnl" "lib/fennel" "lib/fennel.lua" "lib/lume.lua" "lib/stdio.fnl" "lib/stdio.lua")

for file in ${wanted_files[@]}
do
    curl -sS "https://gitlab.com/alexjgriffith/min-love2d-fennel/-/raw/master/${file}" --output "$file"
done
