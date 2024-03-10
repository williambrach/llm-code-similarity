
show_usage() {
    echo "task (C)"
    echo
    echo "Usage: <task.sh> <-h> <-c> <-w> <directory...>"
    echo "<-h>: Shows help"
    echo "<-c>: Counts characters instead of lines"
    echo "<-w>: Counts words instead of lines"
    echo "<directory...>: directories to search, defaults to current directory"
}
search_dirs=()
count_mode=
dir_not_found=0
for arg in "$@"; do
    if [ "$arg" = -h ]; then
        show_usage
        exit 0
    elif [ "$arg" = -c ] || [ "$arg" = -w ]; then
        if [ -n "$count_mode" ]; then
            echo Error: "-w" and "-c" cannot be used together >&2
            exit 1
        fi
        count_mode=$arg
    elif [ "${arg:0:1}" = - ]; then
        echo Error: invalid option "$arg" >&2
        exit 1
    else
        search_dirs+=("$arg")
    fi
done
if [ -z "$count_mode" ]; then
    count_mode=-l
fi
if [ ${#search_dirs[@]} -eq 0 ]; then
    search_dirs+=(".")
fi
process_directory() {
    local current_dir="$1"
    if ! find "$current_dir" 1>/dev/null 2>/dev/null; then
        echo Error: \'"$current_dir"\': directory does not exist >&2
        dir_not_found=1
        return
    fi
    mapfile -t sub_dirs < <(find "$current_dir" -maxdepth 1 -type d ! -path "$current_dir")
    for sub_dir in "${sub_dirs[@]}"; do
        process_directory "$sub_dir"
    done
    mapfile -t files_in_dir < <(find "$current_dir" -maxdepth 1 -type f)
    total_in_dir=0
    for file in "${files_in_dir[@]}"; do
        count=$(wc "$count_mode" <"$file")
        total_in_dir=$((total_in_dir + count))
    done
    if [[ total_in_dir -eq highest_count ]]; then
        highest_count_dirs+=("$current_dir")
    fi
    if [[ total_in_dir -gt highest_count ]]; then
        highest_count=$total_in_dir
        highest_count_dirs=("$current_dir")
    fi
}
for dir in "${search_dirs[@]}"; do
    highest_count=-1
    highest_count_dirs=()
    process_directory "$dir"
    for highest_dir in "${highest_count_dirs[@]}"; do
        echo "$highest_dir" $highest_count
    done
done
if [ "$dir_not_found" -eq 1 ]; then
    exit 2
fi
exit 0
