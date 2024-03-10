
SEARCH_DEPTH=-1
DISPLAY_HELP=false
DIRECTORIES=()
while [ $# -gt 0 ]; do
    case $1 in
    '--help')
        DISPLAY_HELP=true
        ;;
    '--depth')
        shift
        if [ $# -gt 0 ]; then
            SEARCH_DEPTH=$1
            if ! [[ $SEARCH_DEPTH =~ ^[0-9]+$ ]]; then
                echo Error: \'--depth option\': Not a numeric value >&2
                exit 1
            fi
        else
            echo Error: \'--depth option\': No specified depth value >&2
            exit 1
        fi
        ;;
    '--'*)
        echo Error: \'$1\': Unrecognized option >&2
        exit 1
        ;;
    *)
        DIRECTORIES+=("$1")
        ;;
    esac
    shift
done
if [ "$DISPLAY_HELP" = true ]; then
    echo "Usage Instructions"
    echo
    echo "Syntax: $0 [--help] [--depth <value>] [directory...]"
    echo '     --help: Shows help information'
    echo '     --depth: Sets the search depth limit'
    exit
fi
if [ "${#DIRECTORIES[@]}" -eq 0 ]; then
    DIRECTORIES+=(".")
fi
FIND_ARGS=()
FIND_ARGS+=("${DIRECTORIES[@]}")
if ! [ "$SEARCH_DEPTH" -eq -1 ]; then
    FIND_ARGS+=("-maxdepth" "$SEARCH_DEPTH")
fi
SYMLINKS_OUTPUT=$(find "${FIND_ARGS[@]}" -type l 2>&1)
HAS_ERROR=false
SYMLINKS_INFO=()
IFS=$'\n'
for SYMLINK in $SYMLINKS_OUTPUT; do
    if (echo "$SYMLINK" | grep '^find:' >/dev/null); then
        echo 'Error:' "$(echo "$SYMLINK" | cut -d ' ' -f 2-)" >&2
        HAS_ERROR=true
    fi
    SYMLINK_TARGET=$(readlink "$SYMLINK")
    TARGET_COMPONENTS=$(echo "$SYMLINK_TARGET" | awk 'BEGIN { RS = "/" } END { print NR }')
    SYMLINKS_INFO+=("$TARGET_COMPONENTS $SYMLINK $SYMLINK_TARGET")
done
if [ "$HAS_ERROR" = true ]; then
    exit 1
fi
IFS=$'\n'
SORTED_SYMLINKS=$(echo "${SYMLINKS_INFO[*]}" | sort -n)
if [ "$SORTED_SYMLINKS" = "" ]; then
    IFS=" "
    echo "Error: No symbolic links found in '${DIRECTORIES[*]}'" >&2
    exit 1
fi
MOST_LINKS=$(echo "$SORTED_SYMLINKS" | tail -1 | cut -d ' ' -f 1)
echo "$SORTED_SYMLINKS" | grep "^$MOST_LINKS" | awk '{ print $2, "->", $3}'
