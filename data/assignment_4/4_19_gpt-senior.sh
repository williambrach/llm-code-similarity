
instructions="Instructions for use:\nExecute: $0 [-h] [-m <depth>] [directory ...]\n\t-h: show help\n\t-m <depth>: define max search depth\n\tdirectory: directories to be searched"
max_depth=-1
directories_to_search=(".")
longest_link=""
find_links() {
    local current_dir="$1"
    local current_depth="$2"
    current_dir="${current_dir%/}"
    for entry in "$current_dir"/*; do
        if [ -h "$entry" ]; then
            resolved_link="$(readlink -f "$entry")"
            if [ "$current_depth" -le "$max_depth" ] || [ "$max_depth" -eq -1 ]; then
                if [ -z "$longest_link" ] || [ "$(echo "$resolved_link" | grep -o '/' | wc -l)" -gt "$(echo "$longest_link" | grep -o '/' | wc -l)" ]; then
                    longest_link="$entry -> $resolved_link"
                fi
            fi
        elif [ -d "$entry" ]; then
            if [ "$current_depth" -lt "$((max_depth - 1))" ] || [ "$max_depth" -eq -1 ]; then
                find_links "$entry" "$((current_depth + 1))"
            fi
        fi
    done
}
while [ "$#" -gt 0 ]; do
    case "$1" in
    -m | -M | --max-depth)
        if [[ "$2" =~ ^-?[0-9]+$ ]]; then
            if [ "$2" -lt 1 ]; then
                echo "Error: Depth '$2' must be a positive integer." >&2
                exit 1
            fi
            max_depth="$2"
            shift 2
            continue
        else
            echo "Error: Depth '$2' must be a valid number." >&2
            exit 1
        fi
        ;;
    -h | -H | --help)
        echo -e "$instructions"
        exit 0
        ;;
    -*)
        echo "Error: Unknown option '$1'." >&2
        exit 1
        ;;
    *)
        break
        ;;
    esac
done
if [ "$#" -gt 0 ]; then
    directories_to_search=()
    for dir; do
        if [ ! -d "$dir" ]; then
            echo "Error: '$dir' is not a valid directory." >&2
            echo -e "$instructions"
            exit 1
        fi
        directories_to_search+=("$(realpath "$dir")")
    done
fi
for dir in "${directories_to_search[@]}"; do
    find_links "$dir" 0
done
if [ -n "$longest_link" ]; then
    echo "Longest Link Found: '$longest_link'"
else
    echo "No symbolic links were found."
fi
