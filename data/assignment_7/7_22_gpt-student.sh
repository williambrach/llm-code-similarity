
display_usage() {
    echo "$(basename "$0") (C)"
    echo ""
    echo "Usage: $(basename "$0") [-h] [-d <depth>] [path ...]"
    echo "-h - Display this help message"
    echo "-d <depth> - Specify search depth (optional)"
    echo "path - Paths to include in search (optional)"
}

validate_numeric() {
    local num=$1
    if [ "$debug_mode" = true ]; then
        echo "Debug: validate_numeric: '$num'"
    fi
    if [[ "$num" =~ ^[0-9]+$ ]]; then
        return 0 # true
    else
        return 1 # false
    fi
}

find_text() {
    local dir="$1"
    local depth="$2"
    if [ "$debug_mode" = true ]; then
        echo "Debug: dir: '$dir'"
        echo "Debug: depth: '$depth'"
    fi
    if [ -d "$dir" ]; then
        while IFS= read -r -d '' file; do
            occurrences=$(grep -c "$(basename "$file")" "$file")
            if [ "$occurrences" -gt 0 ]; then
                echo "Match: '$file $occurrences'"
            fi
        done < <(find "$dir" -maxdepth "$depth" -type f -name '*.txt' -print0 2> >(sed 's/find/Error/g' >&2))
    else
        echo "Error: '$dir': No such directory." >&2
        exit 1
    fi
}

debug_mode=false # Debugging disabled by default
search_depth=999999 # Default search depth
target_path="." # Default search path
if [ "$debug_mode" = true ]; then
    echo "Working directory: '$(pwd)'"
fi

while getopts ":hd:" opt; do
    if [ "$debug_mode" = true ]; then
        echo "Debug: \$opt \$OPTARG"
        echo "Debug: $opt $OPTARG"
    fi
    case $opt in
    h)
        display_usage
        exit 0
        ;;
    d)
        if validate_numeric "$OPTARG"; then
            search_depth="$OPTARG"
        else
            echo "Error: '-$opt': depth must be a positive integer" >&2
            exit 1
        fi
        if [ "$search_depth" -lt 1 ]; then
            echo "Error: '-$opt': depth must be at least 1" >&2
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

if [ "$debug_mode" = true ]; then
    for arg in "$@"; do
        echo "Debug: Extra argument: '$arg'"
    done
fi

if [ $# -eq 0 ]; then
    find_text "$target_path" "$search_depth"
    exit 0
fi

while [ $# -gt 0 ]; do
    find_text "$1" "$search_depth"
    shift
done
