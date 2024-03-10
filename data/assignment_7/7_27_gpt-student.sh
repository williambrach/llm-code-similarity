
show_help() {
    echo "Application Name (C)" >&1
    echo "Usage: $0 [-h] [-d <depth>] [path ...]" >&1
    echo "-h: Display help text" >&1
    echo "-d <depth>: Descend at most <depth> levels of directories below the command line arguments." >&1
    echo "path: Paths to search (defaults to current directory if none specified)" >&1
    exit 0
}

find_in_directory() {
    local target_path="$1"
    local max_depth="$2"
    local current_file
    local match_count
    for item in "$target_path"/*; do
        item=$(echo "$item" | sed -E 's#/{2,}#/#g; s#/$##')
        if [ -f "$item" ]; then
            current_file="$(basename "$item")"
            current_file="${current_file%.*}"
            if grep -q -- "$current_file" "$item"; then
                match_count=$(grep -c -- "$current_file" "$item")
                echo "Found: '$item $match_count'" >&1
            fi
        elif [ -d "$item" ]; then
            if [ "$max_depth" -ne -1 ] && [ "$max_depth" -gt 1 ]; then
                find_in_directory "$item" "$((max_depth - 1))"
            else
                find_in_directory "$item" -1
            fi
        fi
    done
}

while getopts ":hd:" option; do
    case "$option" in
    h)
        show_help
        ;;
    d)
        if [ -z "$OPTARG" ] || [[ $OPTARG == -* ]]; then
            echo "Error: -d requires a numerical argument." >&2
            exit 4
        elif [[ $OPTARG =~ ^[0-9]+$ ]]; then
            search_depth="$OPTARG"
        else
            echo "Error: Depth must be a number: $OPTARG" >&2
            exit 3
        fi
        ;;
    \?)
        echo "Unknown option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Missing argument for option: -$OPTARG" >&2
        exit 6
        ;;
    esac
done
shift $((OPTIND - 1))

if [ -z "$search_depth" ]; then
    search_depth=-1
fi

if [ "$search_depth" -lt 1 ] && [ "$search_depth" -ne -1 ]; then
    echo "Error: Depth value is not valid." >&2
    exit 2
fi

if [ "$#" -eq 0 ]; then
    find_in_directory "." "$search_depth"
else
    for specified_path in "$@"; do
        if [ ! -e "$specified_path" ]; then
            echo "Warning: Path '$specified_path' does not exist." >&2
        else
            find_in_directory "$specified_path" "$search_depth"
        fi
    done
fi
exit 0
