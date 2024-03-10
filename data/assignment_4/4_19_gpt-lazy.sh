guide="Task 4 (C)\nUsage: $0 [-h] [-m <depth>] [path ...]\n\t-h: display this help message\n\t-m <depth>: set the maximum search depth\n\tpath: directories to search"
search_depth=-1
search_dirs=(".")
longest_sym_link=""
search_links() {
    local folder="$1"
    local depth_level="$2"
    folder="${folder%/}"
    for item in "$folder"/*; do
        if [ -h "$item" ]; then
            link_target="$(readlink -f "$item")"
            if [ "$depth_level" -le "$search_depth" ] || [ "$search_depth" -eq -1 ]; then
                if [ -z "$longest_sym_link" ] || [ "$(tr '/' '\n' <<<"$link_target" | wc -l)" -gt "$(tr '/' '\n' <<<"$longest_sym_link" | wc -l)" ]; then
                    longest_sym_link="$item -> $link_target"
                fi
            fi
        elif [ -d "$item" ]; then
            if [ "$depth_level" -lt "$((search_depth - 1))" ] || [ "$search_depth" -eq -1 ]; then
                search_links "$item" "$((depth_level + 1))"
            fi
        fi
    done
}
while (("$#")); do
    case "$1" in
    -m | -M | --max-depth)
        if [ "$2" -eq "$2" ] 2>/dev/null; then
            if [ "$2" -lt 1 ]; then
                echo "Error: '$2': depth must be greater than 0" >&2
                exit 1
            fi
            search_depth="$2"
            shift 2
            break
        else
            echo "Error: '$2': depth must be a number" >&2
            exit 1
        fi
        ;;
    -h | -H | --help)
        echo -e "$guide"
        exit 0
        ;;
    -*)
        echo "Error: '$1': unknown option" >&2
        exit 1
        ;;
    *)
        break
        ;;
    esac
done
for arg in "$@"; do
    if [ ! -d "$arg" ]; then
        echo "Error: '$arg': is not a directory" >&2
        echo -e "$guide"
        exit 1
    fi
done
if [ $# -gt 0 ]; then
    search_dirs=()
    while (("$#")); do
        search_dirs+=("$(realpath "$1")")
        shift
    done
fi
for folder in "${search_dirs[@]}"; do
    search_links "$folder" 0
done
if [ -n "$longest_sym_link" ]; then
    echo "Output: '$longest_sym_link'"
else
    echo "Output: 'No symbolic links found'"
fi
exit 0
