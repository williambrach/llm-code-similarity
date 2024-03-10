
display_help() {
    echo "task (C)"
    echo
    echo "Usage: <task.sh> <-h> <-c> <-w> <directory...>"
    echo "<-h>: Shows help"
    echo "<-c>: Counts characters instead of lines"
    echo "<-w>: Counts words instead of lines"
    echo "<directory...>: directories to search, defaults to current directory"
}
directories=()
mode=
missing_directory_error=0
for parameter in "$@"; do
    if [ "$parameter" = -h ]; then
        display_help
        exit 0
    elif [ "$parameter" = -c ]; then
        if [ -n "$mode" ]; then
            echo Error: "-w" and "-c" cannot be used together >&2
            exit 1
        fi
        mode=$parameter
    elif [ "$parameter" = -w ]; then
        if [ -n "$mode" ]; then
            echo Error: "-w" and "-c" cannot be used together >&2
            exit 1
        fi
        mode=$parameter
    elif [ "${parameter:0:1}" = - ]; then
        echo Error: invalid option "$parameter" >&2
        exit 1
    else
        directories+=("$parameter")
    fi
done
if [ -z "$mode" ]; then
    mode=-l
fi
if [ ${#directories[@]} -eq 0 ]; then
    directories+=(".")
fi
analyze_directory() {
    local dir="$1"
    if ! find "$dir" 1>/dev/null 2>/dev/null; then
        echo Error: \'"$dir"\': directory does not exist >&2
        missing_directory_error=1
        return
    fi
    mapfile -t inner_dirs < <(find "$dir" -maxdepth 1 -type d ! -path "$dir")
    for inner_dir in "${inner_dirs[@]}"; do
        analyze_directory "$inner_dir"
    done
    mapfile -t dir_files < <(find "$dir" -maxdepth 1 -type f)
    dir_total=0
    for dir_file in "${dir_files[@]}"; do
        file_count=$(wc "$mode" <"$dir_file")
        dir_total=$((dir_total + file_count))
    done
    if [[ dir_total -eq max_count ]]; then
        max_count_dirs+=("$dir")
    fi
    if [[ dir_total -gt max_count ]]; then
        max_count=$dir_total
        max_count_dirs=("$dir")
    fi
}
for directory in "${directories[@]}"; do
    max_count=-1
    max_count_dirs=()
    analyze_directory "$directory"
    for max_dir in "${max_count_dirs[@]}"; do
        echo "$max_dir" $max_count
    done
done
if [ "$missing_directory_error" -eq 1 ]; then
    exit 2
fi
exit 0
