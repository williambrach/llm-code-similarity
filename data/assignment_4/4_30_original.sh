
show_usage() {
    echo "run_script.sh (C)"
    echo
    echo "Syntax: run_script.sh [-h] [-d <depth>] [path ...]"
    echo "-h: Display help text"
    echo "-d: <depth>: Specify search depth"
    echo "path: paths to include in search"
    echo
}

refresh_longest_symlink() {
    if [ "$1" -gt "${max_symlink_length[0]}" ]; then
        max_symlink_length=("$1")
        max_symlink_name=("$2")
        resolved_path=("$(readlink -f "$2")")
    elif [ "$1" -eq "${max_symlink_length[0]}" ]; then
        max_symlink_length+=("$1")
        max_symlink_name+=("$2")
        resolved_path+=("$(readlink -f "$2")")
    fi
}

calculate_path_segments() {
    local target="$1"
    local size=${#target}
    if [ "$size" -eq 1 ]; then
        echo "1"
    else
        echo "$target" | tr '/' '\n' | wc -l
    fi
}

display_outcomes() {
    local count=${#max_symlink_length[@]}
    if [ "${max_symlink_length[0]}" -gt 0 ]; then
        for ((i = 0; i < "$count"; i++)); do
            echo "${max_symlink_name[$i]}" '->' "${resolved_path[$i]}"
        done
    fi
}

depth_limit=-1
if [ "$1" == "-h" ]; then
    show_usage
    shift
fi
if [ "$1" == "-d" ]; then
    if [ "$2" -gt 0 ]; then
        depth_limit="$2"
        shift 2
    else
        echo "Error: '$2': Depth must be greater than zero" >&2
        exit 1
    fi
fi
paths=("$@")
for path in "${paths[@]}"; do
    if ! [[ -d "$path" ]]; then
        echo "Error: '$path': Directory does not exist" >&2
    else
        valid_paths+=("$path")
    fi
done
if [ ${#paths[@]} -eq 0 ]; then
    paths=(".")
else
    paths=("${valid_paths[@]}")
fi
max_symlink_length=(0)
if [ ${#paths[@]} -eq 0 ]; then
    exit 1
fi
for path in "${paths[@]}"; do
    if [ "$depth_limit" -ne -1 ]; then
        while IFS= read -r -d '' link; do
            link_path=$(readlink -f "$link")
            segment_count=$(calculate_path_segments "$link_path")
            if [ "$segment_count" -ge "${max_symlink_length[0]}" ]; then
                refresh_longest_symlink "$segment_count" "$link"
            fi
        done < <(find "$path" -maxdepth "$depth_limit" -type l -print0)
    else
        while IFS= read -r -d '' link; do
            link_path=$(readlink -f "$link")
            segment_count=$(calculate_path_segments "$link_path")
            if [ "$segment_count" -ge "${max_symlink_length[0]}" ]; then
                refresh_longest_symlink "$segment_count" "$link"
            fi
        done < <(find "$path" -type l -print0)
    fi
done
display_outcomes
