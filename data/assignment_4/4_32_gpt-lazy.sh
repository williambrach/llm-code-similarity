SEARCH_DEPTH=-1
SHOW_HELP=false
DIRECTORIES=()
while [ $# -gt 0 ]; do
    case $1 in
    '--help')
        SHOW_HELP=true
        ;;
    '--depth')
        shift
        if [ $# -gt 0 ]; then
            SEARCH_DEPTH=$1
            if ! [[ $SEARCH_DEPTH =~ ^[0-9]+$ ]]; then
                echo Error: \'option --depth\': Value is not a number >&2
                exit 1
            fi
        else
            echo Error: \'option --depth\': Missing value for depth parameter >&2
            exit 1
        fi
        ;;
    '--'*)
        echo Error: \'option\': Invalid option "$1" >&2
        exit 1
        ;;
    *)
        DIRECTORIES+=("$1")
        ;;
    esac
    shift
done
if [ "$SHOW_HELP" = true ]; then
    echo "Homework4 (C)"
    echo
    echo "Usage: $0 [--help] [--depth <depth>] [directories...]"
    echo '     --help: Display this help message and exit'
    echo '     --depth: Specify maximum search depth'
    exit
fi
if [ "${#DIRECTORIES[@]}" -eq 0 ]; then
    DIRECTORIES+=(".")
fi
PARAMS=()
PARAMS+=("${DIRECTORIES[@]}")
if ! [ "$SEARCH_DEPTH" -eq -1 ]; then
    PARAMS+=("-maxdepth" "$SEARCH_DEPTH")
fi
SYMLINKS=$(find "${PARAMS[@]}" -type l 2>&1)
ERROR_OCCURRED=false
LINKS_FOUND=()
IFS=$'\n'
for SYMLINK in $SYMLINKS; do
    if (echo "$SYMLINK" | grep '^find:' >/dev/null); then
        echo 'Error:' "$(echo "$SYMLINK" | cut -d ' ' -f 2-)" >&2
        ERROR_OCCURRED=true
    fi
    SYMLINK_TARGET=$(readlink "$SYMLINK")
    PATH_PARTS=$(echo "$SYMLINK_TARGET" | awk 'BEGIN { RS = "/" } END { print NR }')
    LINKS_FOUND+=("$PATH_PARTS $SYMLINK $SYMLINK_TARGET")
done
if [ "$ERROR_OCCURRED" = true ]; then
    exit 1
fi
IFS=$'\n'
ORDERED_LINKS=$(echo "${LINKS_FOUND[*]}" | sort -n)
if [ "$ORDERED_LINKS" = "" ]; then
    IFS=" "
    echo "Error: '${DIRECTORIES[*]}': No links found" >&2
    exit 1
fi
HIGHEST_COUNT=$(echo "$ORDERED_LINKS" | tail -1 | cut -d ' ' -f 1)
echo "$ORDERED_LINKS" | grep "^$HIGHEST_COUNT" | awk '{ print $2, "->", $3}'
