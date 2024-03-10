
show_help() {
    echo "Script Name: $(basename "$0") (C)"
    echo ""
    echo "How to use: $(basename "$0") [-h] [-d <depth>] [directory ...]"
    echo "-h - Show help information"
    echo "-d <depth> - Define search depth (optional)"
    echo "directory - Directories to search (optional)"
}

check_if_number() {
    local value=$1
    if [ "$debug" = true ]; then
        echo "Debug: Checking number: '$value'"
    fi
    if [[ "$value" =~ ^[0-9]+$ ]]; then
        return 0 # success
    else
        return 1 # failure
    fi
}

search_for_text() {
    local search_dir="$1"
    local search_depth="$2"
    if [ "$debug" = true ]; then
        echo "Debug: Searching in: '$search_dir'"
        echo "Debug: With depth: '$search_depth'"
    fi
    if [ -d "$search_dir" ]; then
        while IFS= read -r -d '' file; do
            count=$(grep -c "$(basename "$file")" "$file")
            if [ "$count" -gt 0 ]; then
                echo "Found: '$file $count'"
            fi
        done < <(find "$search_dir" -maxdepth "$search_depth" -type f -name '*.txt' -print0 2> >(sed 's/find/Error/g' >&2))
    else
        echo "Error: Directory '$search_dir' does not exist." >&2
        exit 1
    fi
}

debug=false # Debug mode off by default
depth_limit=999999 # Default maximum search depth
search_dir="." # Default directory to search
if [ "$debug" = true ]; then
    echo "Current directory: '$(pwd)'"
fi

while getopts ":hd:" option; do
    if [ "$debug" = true ]; then
        echo "Debug: Option and argument: $option $OPTARG"
    fi
    case $option in
    h)
        show_help
        exit 0
        ;;
    d)
        if check_if_number "$OPTARG"; then
            depth_limit="$OPTARG"
        else
            echo "Error: Option '-$option' requires a positive integer" >&2
            exit 1
        fi
        if [ "$depth_limit" -lt 1 ]; then
            echo "Error: Option '-$option' requires a depth of at least 1" >&2
            exit 1
        fi
        ;;
    :)
        echo "Error: Option '-$OPTARG' needs a value" >&2
        exit 1
        ;;
    \?)
        echo "Error: Unknown option '-$OPTARG'" >&2
        exit 1
        ;;
    esac
done

shift $((OPTIND - 1))

if [ "$debug" = true ]; then
    for arg in "$@"; do
        echo "Debug: Additional argument: '$arg'"
    done
fi

if [ $# -eq 0 ]; then
    search_for_text "$search_dir" "$depth_limit"
    exit 0
fi

while [ $# -gt 0 ]; do
    search_for_text "$1" "$depth_limit"
    shift
done
