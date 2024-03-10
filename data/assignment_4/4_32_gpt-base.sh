
NEED_HELP=false
FOLDER_LIST=()
SEARCH_LIMIT=-1
while [ $# -gt 0 ]; do
    case $1 in
    '--help')
        NEED_HELP=true
        ;;
    '--depth')
        shift
        if [ $# -eq 0 ]; then
            echo Error: Missing value for \'--depth\' option >&2
            exit 1
        else
            SEARCH_LIMIT=$1
            if ! [[ $SEARCH_LIMIT =~ ^-?[0-9]+$ ]]; then
                echo Error: \'--depth\' requires a numeric value >&2
                exit 1
            fi
        fi
        ;;
    '--'*)
        echo Error: Unsupported option \'$1\' >&2
        exit 1
        ;;
    *)
        FOLDER_LIST+=("$1")
        ;;
    esac
    shift
done
if $NEED_HELP; then
    echo "Help Information"
    echo
    echo "Usage: $0 [--help] [--depth <number>] [path...]"
    echo 'Options:'
    echo '     --help: Display this help message'
    echo '     --depth <number>: Specify search depth'
    exit
fi
if [ ${#FOLDER_LIST[@]} -eq 0 ]; then
    FOLDER_LIST+=(".")
fi
ARGS_FIND=()
ARGS_FIND+=("${FOLDER_LIST[@]}")
if [ $SEARCH_LIMIT -ne -1 ]; then
    ARGS_FIND+=("-maxdepth" "$SEARCH_LIMIT")
fi
LINKS_FOUND=$(find "${ARGS_FIND[@]}" -type l 2>&1)
ERROR_FOUND=false
LINKS_DETAILS=()
IFS=$'\n'
for LINK in $LINKS_FOUND; do
    if echo "$LINK" | grep -q '^find:'; then
        echo 'Error:' "$(echo "$LINK" | cut -d ' ' -f 2-)" >&2
        ERROR_FOUND=true
    else
        LINK_PATH=$(readlink "$LINK")
        PATH_PARTS=$(echo "$LINK_PATH" | awk 'BEGIN { RS = "/" } END { print NR }')
        LINKS_DETAILS+=("$PATH_PARTS $LINK $LINK_PATH")
    fi
done
if $ERROR_FOUND; then
    exit 1
fi
IFS=$'\n'
LINKS_SORTED=$(echo "${LINKS_DETAILS[*]}" | sort -n)
if [ -z "$LINKS_SORTED" ]; then
    IFS=" "
    echo "Error: No symbolic links found in the specified paths" >&2
    exit 1
fi
MAX_LINKS=$(echo "$LINKS_SORTED" | tail -1 | cut -d ' ' -f 1)
echo "$LINKS_SORTED" | grep "^$MAX_LINKS" | awk '{ print $2, "->", $3}'
