
show_usage() {
    echo "TASK 4"
    echo "Usage: $0 [-h] [-d <depth>] [directory ...]"
    echo "        -h: Display this help message"
    echo "        -d N: Set search depth"
    echo "        <directory1 directory2 ...>: Directories to search. Defaults to current directory if none specified."
}

# Reset variables
unset depth
unset directories

parse_arguments() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
        -h)
            show_usage
            exit 0
            ;;
        -d)
            if [ "$#" -lt 2 ]; then
                echo "Error: '-d' needs a value." >&2
                exit 1
            fi
            if ! [[ "$2" =~ ^[0-9]+$ ]]; then
                echo "Error: '-d $2' must be a positive integer." >&2
                exit 1
            fi
            if [ "$2" -lt 1 ]; then
                echo "Error: '-d $2' must be at least 1." >&2
                exit 1
            fi
            shift
            depth=$1
            ;;
        -*)
            echo "Error: Unknown option '$1'." >&2
            exit 1
            ;;
        *)
            if [ ! -d "$1" ]; then
                echo "Error: '$1' is not a valid directory." >&2
                exit 1
            fi
            if [[ ! " ${directories[*]} " =~ $1 ]]; then
                directories+=("$1")
            fi
            ;;
        esac
        shift
    done
}

parse_arguments "$@"

if [ -z "${directories[*]}" ]; then
    directories+=("$(pwd)")
fi

find_links() {
    local dir=$1
    local symlinks=()
    local targets=()
    local cmd="find \"$dir\" -type l"
    if [ ! -z "$depth" ]; then
        cmd+=" -maxdepth $depth"
    fi
    while IFS= read -r -d '' link; do
        symlinks+=("$link")
        targets+=("$(readlink -f "$link")")
    done < <(eval "$cmd -print0")

    max_depth=0
    for target in "${targets[@]}"; do
        depth=$(tr -dc '/' <<<"$target" | wc -c)
        if [ "$depth" -gt "$max_depth" ]; then
            max_depth="$depth"
        fi
    done

    for i in "${!symlinks[@]}"; do
        if [ "$(tr -dc '/' <<<"${targets[$i]}" | wc -c)" -eq "$max_depth" ]; then
            echo "Deepest: '${symlinks[$i]} -> ${targets[$i]}'"
        fi
    done
}

for dir in "${directories[@]}"; do
    find_links "$dir"
done

exit 0
