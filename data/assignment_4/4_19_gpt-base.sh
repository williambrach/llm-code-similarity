
help_text="How to use:\nExecute: $0 [-h] [-d <depth>] [directory ...]\n\t-h: show help\n\t-d <depth>: define max search depth\n\tdirectory: directories to be searched"
max_depth=-1
directories_to_search=(".")
longest_link=""
find_links() {
    local dir="$1"
    local current_depth="$2"
    dir="${dir%/}"
    for entry in "$dir"/*; do
        if [ -h "$entry" ]; then
            resolved_path="$(readlink -f "$entry")"
            if [ "$current_depth" -le "$max_depth" ] || [ "$max_depth" -eq -1 ]; then
                if [ -z "$longest_link" ] || [ "$(echo "$resolved_path" | tr -cd '/' | wc -c)" -gt "$(echo "$longest_link" | tr -cd '/' | wc -c)" ]; then
                    longest_link="$entry -> $resolved_path"
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
    -d | --depth)
        if [[ "$2" =~ ^-?[0-9]+$ ]]; then
            if [ "$2" -lt 1 ]; then
                echo "Error: Depth value '$2' must be greater than zero." >&2
                exit 1
            fi
            max_depth="$2"
            shift 2
            continue
        else
            echo "Error: Depth value '$2' must be a number." >&2
            exit 1
        fi
        ;;
    -h | --help)
        echo -e "$help_text"
        exit 0
        ;;
    -*)
        echo "Error: Unrecognized option '$1'." >&2
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
            echo "Error: '$dir' is not a directory." >&2
            echo -e "$help_text"
            exit 1
        fi
        directories_to_search+=("$(realpath "$dir")")
    done
fi
for dir in "${directories_to_search[@]}"; do
    find_links "$dir" 0
done
if [ -n "$longest_link" ]; then
    echo "Longest Symbolic Link Found: '$longest_link'"
else
    echo "No symbolic links detected."
fi
