
display_help() {
    echo "TASK 4"
    echo "How to use: $0 [-h] [-d <depth>] [directory ...]"
    echo "        -h: Show this help message"
    echo "        -d N: Specify search depth"
    echo "        <directory1 directory2 ...>: List of directories to search. If none specified, defaults to current directory."
}

# Clear variables
unset depth_option
unset search_dirs

process_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
        -h)
            display_help
            exit 0
            ;;
        -d)
            if [ "$#" -lt 2 ]; then
                echo "Error: Option '-d' requires an argument." >&2
                exit 1
            fi
            if ! [[ "$2" =~ ^[0-9]+$ ]]; then
                echo "Error: '-d $2' requires a positive integer." >&2
                exit 1
            fi
            if [ "$2" -lt 1 ]; then
                echo "Error: '-d $2' value must be 1 or greater." >&2
                exit 1
            fi
            shift
            depth_option=$1
            ;;
        -*)
            echo "Error: Unrecognized option '$1'." >&2
            exit 1
            ;;
        *)
            if [ ! -d "$1" ]; then
                echo "Error: Directory '$1' does not exist." >&2
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

process_args "$@"

if [ -z "${search_dirs[*]}" ]; then
    search_dirs+=("$(pwd)")
fi

find_deepest_links() {
    local search_dir=$1
    local links=()
    local targets=()
    local find_cmd="find \"$search_dir\" -type l"
    if [ ! -z "$depth_option" ]; then
        find_cmd+=" -maxdepth $depth_option"
    fi
    while IFS= read -r -d '' link; do
        links+=("$link")
        targets+=("$(readlink -f "$link")")
    done < <(eval "$find_cmd -print0")

    deepest=0
    for target in "${targets[@]}"; do
        depth=$(tr -dc '/' <<<"$target" | wc -c)
        if [ "$depth" -gt "$deepest" ]; then
            deepest="$depth"
        fi
    done

    for i in "${!links[@]}"; do
        if [ "$(tr -dc '/' <<<"${targets[$i]}" | wc -c)" -eq "$deepest" ]; then
            echo "Deepest: '${links[$i]} -> ${targets[$i]}'"
        fi
    done
}

for directory in "${search_dirs[@]}"; do
    find_deepest_links "$directory"
done

exit 0
