MAX_DEPTH=-1
FIND_DIR=.
show_help() {
    echo "search_script.sh "
    echo
    echo "Usage: search_script.sh [-h] [-m <depth>] [directory ...]"
    echo "   -h: Display this help message"
    echo "   -m <depth>: Limit the search depth of directories"
    echo "   directory: Directories to search in"
    exit 0
}
while getopts "hm:" option; do
    case "$option" in
    h)
        show_help
        ;;
    m)
        MAX_DEPTH=$OPTARG
        ;;
    \?)
        echo "Error: 'Invalid option'" >&2
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))
if [ $# -gt 0 ]; then
    FIND_DIR="$@"
fi
find_files() {
    local dir="$1"
    local depth="$2"
    command='find $dir'
    if [ "$depth" -gt -1 ]; then
        command="$command -maxdepth $depth"
    fi
    command="$command -type f -print0"
    while IFS= read -r -d '' file; do
        file_name=$(basename "$file")
        if grep -q -- "$file_name" "$file"; then
            echo "Found: '$file $(grep -c -- "$file_name" "$file")'"
        fi
    done < <(eval "$command")
    exit 0
}
find_files "$FIND_DIR" "$MAX_DEPTH"
