
show_help() {
    echo "$(basename "$0") (C)"
    echo ""
    echo "Usage: $(basename "$0") [-h] [-d <depth>] [path ...]"
    echo "-h - Display this help message"
    echo "-d <depth> - Specify search depth (optional)"
    echo "path - Paths to include in search (optional)"
}
is_numeric() {
    local value=$1
    if [ "$debug" = true ]; then
        echo "Debug: is_numeric: '$value'"
    fi
    if [[ "$value" =~ ^[0-9]+$ ]]; then
        return 0 # true
    else
        return 1 # false
    fi
}
search_for_text() {
    local search_path="$1"
    local search_depth="$2"
    if [ "$debug" = true ]; then
        echo "Debug: search_path: '$search_path'"
        echo "Debug: search_depth: '$search_depth'"
    fi
    if [ -d "$search_path" ]; then
        while IFS= read -r -d '' file; do
            count=$(grep -c "$(basename "$file")" "$file")
            if [ "$count" -gt 0 ]; then
                echo "Match: '$file $count'"
            fi
        done < <(find "$search_path" -maxdepth "$search_depth" -type f -name '*.txt' -print0 2> >(sed 's/find/Error/g' >&2))
    else
        echo "Error: '$search_path': No such directory." >&2
        exit 1
    fi
}
debug=false # Debugging disabled by default
depth=999999 # Default search depth
search_path="." # Default search path
if [ "$debug" = true ]; then
    echo "Working directory: '$(pwd)'"
fi
while getopts ":hd:" option; do
    if [ "$debug" = true ]; then
        echo "Debug: \$option \$OPTARG"
        echo "Debug: $option $OPTARG"
    fi
    case $option in
    h)
        show_help
        exit 0
        ;;
    d)
        if is_numeric "$OPTARG"; then
            depth="$OPTARG"
        else
            echo "Error: '-$option': depth must be a positive integer" >&2
            exit 1
        fi
        if [ "$depth" -lt 1 ]; then
            echo "Error: '-$option': depth must be at least 1" >&2
            exit 1
        fi
        ;;
    :)
        echo "Error: '-$OPTARG' requires an argument" >&2
        exit 1
        ;;
    \?)
        echo "Error: Invalid option '-$OPTARG'" >&2
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))
if [ "$debug" = true ]; then
    for arg in "$@"; do
        echo "Debug: Extra argument: '$arg'"
    done
fi
if [ $# -eq 0 ]; then
    search_for_text "$search_path" "$depth"
    exit 0
fi
while [ $# -gt 0 ]; do
    search_for_text "$1" "$depth"
    shift
done
