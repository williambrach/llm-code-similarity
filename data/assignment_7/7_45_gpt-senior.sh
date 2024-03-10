
DEPTH_LIMIT=-1
SEARCH_ROOT=.
display_usage() {
    echo "Usage: $0 [-h] [-d <depth>] [path ...]"
    echo "Options:"
    echo "  -h: Show this help message"
    echo "  -d <depth>: Set the maximum depth for directory search"
    echo "  path: Specify the root directories for the search"
    exit 0
}
while getopts "hd:" opt; do
    case $opt in
    h)
        display_usage
        ;;
    d)
        DEPTH_LIMIT=$OPTARG
        ;;
    *)
        echo "Error: Invalid command option" >&2
        exit 1
        ;;
    esac
done
shift $((OPTIND-1))
if [ $# -ne 0 ]; then
    SEARCH_ROOT="$@"
fi
search_files() {
    local root_path="$1"
    local depth="$2"
    find_cmd="find $root_path"
    if [ "$depth" -ne -1 ]; then
        find_cmd+=" -maxdepth $depth"
    fi
    find_cmd+=" -type f -print0"
    while IFS= read -r -d '' file_path; do
        file_basename=$(basename "$file_path")
        if grep -q -- "$file_basename" "$file_path"; then
            echo "Match: '$file_path $(grep -c -- "$file_basename" "$file_path")'"
        fi
    done < <(eval "$find_cmd")
    exit 0
}
search_files "$SEARCH_ROOT" "$DEPTH_LIMIT"
