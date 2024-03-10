
MAX_DEPTH=-1
HELP_FLAG=false
FOLDERS=()
while [ $# -gt 0 ]; do
    case $1 in
    '--help')
        HELP_FLAG=true
        ;;
    '--depth')
        shift
        if [ $# -gt 0 ]; then
            MAX_DEPTH=$1
            if ! [[ $MAX_DEPTH =~ ^[0-9]+$ ]]; then
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
        FOLDERS+=("$1")
        ;;
    esac
    shift
done
if [ "$HELP_FLAG" = true ]; then
    echo "Usage Instructions"
    echo
    echo "Syntax: $0 [--help] [--depth <value>] [folder...]"
    echo '     --help: Shows help information'
    echo '     --depth: Sets the search depth limit'
    exit
fi
if [ "${#FOLDERS[@]}" -eq 0 ]; then
    FOLDERS+=(".")
fi
ARGS=()
ARGS+=("${FOLDERS[@]}")
if ! [ "$MAX_DEPTH" -eq -1 ]; then
    ARGS+=("-maxdepth" "$MAX_DEPTH")
fi
LINK_OUTPUT=$(find "${ARGS[@]}" -type l 2>&1)
ERROR_FLAG=false
FOUND_LINKS=()
IFS=$'\n'
for LINK in $LINK_OUTPUT; do
    if (echo "$LINK" | grep '^find:' >/dev/null); then
        echo 'Error:' "$(echo "$LINK" | cut -d ' ' -f 2-)" >&2
        ERROR_FLAG=true
    fi
    LINK_DEST=$(readlink "$LINK")
    DEST_PARTS=$(echo "$LINK_DEST" | awk 'BEGIN { RS = "/" } END { print NR }')
    FOUND_LINKS+=("$DEST_PARTS $LINK $LINK_DEST")
done
if [ "$ERROR_FLAG" = true ]; then
    exit 1
fi
IFS=$'\n'
SORTED_LINKS=$(echo "${FOUND_LINKS[*]}" | sort -n)
if [ "$SORTED_LINKS" = "" ]; then
    IFS=" "
    echo "Error: No symbolic links found in '${FOLDERS[*]}'" >&2
    exit 1
fi
TOP_COUNT=$(echo "$SORTED_LINKS" | tail -1 | cut -d ' ' -f 1)
echo "$SORTED_LINKS" | grep "^$TOP_COUNT" | awk '{ print $2, "->", $3}'
