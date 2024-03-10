
display_help() {
    echo "TASK 4"
    echo "How to use: $0 [-h] [-d <depth>] [directory ...]"
    echo "        -h: Show help information"
    echo "        -d N: Define search depth"
    echo "        <directory1 directory2 ...>: Search directories. Uses current directory by default if none are given."
}

# Clear variables
unset search_depth
unset search_dirs

handle_input() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
        -h)
            display_help
            exit 0
            ;;
        -d)
            if [ "$#" -lt 2 ]; then
                echo "Error: '-d' requires a numerical value." >&2
                exit 1
            fi
            if ! [[ "$2" =~ ^[0-9]+$ ]]; then
                echo "Error: '-d $2' should be a positive number." >&2
                exit 1
            fi
            if [ "$2" -lt 1 ]; then
                echo "Error: '-d $2' value must be 1 or greater." >&2
                exit 1
            fi
            shift
            search_depth=$1
            ;;
        -*)
            echo "Error: Unrecognized option '$1'." >&2
            exit 1
            ;;
        *)
            if [ ! -d "$1" ]; then
                echo "Error: '$1' is not a directory." >&2
                exit 1
            fi
            if [[ ! " ${search_dirs[*]} " =~ $1 ]]; then
                search_dirs+=("$1")
            fi
            ;;
        esac
        shift
    done
}

handle_input "$@"

if [ -z "${search_dirs[*]}" ]; then
    search_dirs+=("$(pwd)")
fi

search_symlinks() {
    local search_dir=$1
    local links=()
    local link_targets=()
    local find_cmd="find \"$search_dir\" -type l"
    if [ ! -z "$search_depth" ]; then
        find_cmd+=" -maxdepth $search_depth"
    fi
    while IFS= read -r -d '' symlink; do
        links+=("$symlink")
        link_targets+=("$(readlink -f "$symlink")")
    done < <(eval "$find_cmd -print0")

    deepest=0
    for target in "${link_targets[@]}"; do
        depth_count=$(tr -dc '/' <<<"$target" | wc -c)
        if [ "$depth_count" -gt "$deepest" ]; then
            deepest="$depth_count"
        fi
    done

    for i in "${!links[@]}"; do
        if [ "$(tr -dc '/' <<<"${link_targets[$i]}" | wc -c)" -eq "$deepest" ]; then
            echo "Deepest Link: '${links[$i]} -> ${link_targets[$i]}'"
        fi
    done
}

for search_dir in "${search_dirs[@]}"; do
    search_symlinks "$search_dir"
done

exit 0
