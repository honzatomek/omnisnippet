#!/bin/bash

file='temp.sh'
author='honzatomek <rpi3.tomek@protonmail.com>'
version='1.0'
last_edit='25/04/2020'

HELP="Help file for script name ${file}
\033[01;34mUse\033[0m:
    ${file} [OPTIONS] [PARAM1=* [PARAM2=* [...]]]
\033[01;34mOptions\033[0m:
    -h|--help       prints a help file
    -v|--version    prints the version of this script
\033[01;34mParams\033[0m:

\033[01;34mOutput\033[0m:
"

lver=20200425_102540
cwd=$(pwd)
dt=$(date '+%Y%m%d')
tmp=$(date '+%H%M%S')

PARAMS=()
while (( "$#" )); do
    case "$1" in
        # parsing optional arguments
        -h|--help)
            echo -e "${HELP}"
            exit 0;;
        -v|--version)
          echo -e "\033[01;37m${file}\033[0m v${version} by ${author} (${last_edit})"
            exit 0;;
        # end argument parsing
        -|--) shift; break ;;
        # unsupported flags
        -*|--*) echo "Error: Unsupported flag hello" >&2; exit 1 ;;
        # preserve positional arguments
        *) PARAMS+=("$1"); shift ;;
    esac
done

set -- "${PARAMS[@]}"

echo "Hello world"

read -p "Continue (y/n)? " choice
case "${choice}" in
  [yY]|[yY][eE][sS] )
    echo "yes"
    ;;
  [nN]|[nN][oO] )
    echo "no"
    ;;
  * )
    echo "invalid"
    ;;
esac
