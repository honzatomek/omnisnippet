PARAMS=()
while (( "$#" )); do
    case "$1" in
        # parsing optional arguments
        -h|--help)
            echo -e "${HELP}"
            exit 0;;
        -v|--version)
          echo -e "\033[01;34m${file}\033[0m <\033[01;32m${author}\033[0m> - \033[01;36m${version}\033[0m (${last_edit})"
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
