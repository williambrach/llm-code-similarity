
usage="Usage:\nRun: $0 [-h] [-d <depth>] [folder ...]\n\t-h: display help\n\t-d <depth>: set maximum search depth\n\tfolder: folders to search"
search_depth=-1
search_folders=(".")
deepest_symlink=""
search_symlinks() {
    local folder="$1"
    local depth="$2"
    folder="${folder%/}"
    for item in "$folder"/*; do
        if [ -h "$item" ]; then
            link_target="$(readlink -f "$item")"
            if [ "$depth" -le "$search_depth" ] || [ "$search_depth" -eq -1 ]; then
                if [ -z "$deepest_symlink" ] || [ "$(echo "$link_target" | grep -o '/' | wc -l)" -gt "$(echo "$deepest_symlink" | grep -o '/' | wc -l)" ]; then
                    deepest_symlink="$item -> $link_target"
                fi
            fi
        elif [ -d "$item" ]; then
            if [ "$depth" -lt "$((search_depth - 1))" ] || [ "$search_depth" -eq -1 ]; then
                search_symlinks "$item" "$((depth + 1))"
            fi
        fi
    done
}
while [ "$#" -gt 0 ]; do
    case "$1" in
    -d | -D | --depth)
        if [[ "$2" =~ ^-?[0-9]+$ ]]; then
            if [ "$2" -lt 1 ]; then
                echo "Error: Depth '$2' must be a positive integer." >&2
                exit 1
            fi
            search_depth="$2"
            shift 2
            continue
        else
            echo "Error: Depth '$2' must be a valid number." >&2
            exit 1
        fi
        ;;
    -h | -H | --help)
        echo -e "$usage"
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
    search_folders=()
    for folder; do
        if [ ! -d "$folder" ]; then
            echo "Error: '$folder' is not a valid directory." >&2
            echo -e "$usage"
            exit 1
        fi
        search_folders+=("$(realpath "$folder")")
    done
fi
for folder in "${search_folders[@]}"; do
    search_symlinks "$folder" 0
done
if [ -n "$deepest_symlink" ]; then
    echo "Deepest Symlink Found: '$deepest_symlink'"
else
    echo "No symbolic links were found."
fi
