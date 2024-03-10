
display_help() {
    echo "Task (C)"
    echo
    echo "Syntax: <task.sh> [-h] [-c] [-w] [directory...]"
    echo "-h: Display this help message"
    echo "-c: Count characters instead of lines"
    echo "-w: Count words instead of lines"
    echo "[directory...]: Directories to analyze, defaults to the current directory if none specified"
}
directories_to_search=()
mode_of_counting=
missing_directory=0
for parameter in "$@"; do
    if [ "$parameter" = "-h" ]; then
        display_help
        exit 0
    elif [ "$parameter" = "-c" ] || [ "$parameter" = "-w" ]; then
        if [ ! -z "$mode_of_counting" ]; then
            echo Error: Cannot use "-c" and "-w" simultaneously >&2
            exit 1
        fi
        mode_of_counting=$parameter
    elif [ "${parameter:0:1}" = "-" ]; then
        echo Error: Unrecognized option "$parameter" >&2
        exit 1
    else
        directories_to_search+=("$parameter")
    fi
done
if [ -z "$mode_of_counting" ]; then
    mode_of_counting=-l
fi
if [ ${#directories_to_search[@]} -eq 0 ]; then
    directories_to_search+=(".")
fi
analyze_directory() {
    local target_dir="$1"
    if ! find "$target_dir" 1>/dev/null 2>/dev/null; then
        echo Error: Directory '"$target_dir"' not found >&2
        missing_directory=1
        return
    fi
    mapfile -t child_dirs < <(find "$target_dir" -maxdepth 1 -type d ! -path "$target_dir")
    for child_dir in "${child_dirs[@]}"; do
        analyze_directory "$child_dir"
    done
    mapfile -t directory_files < <(find "$target_dir" -maxdepth 1 -type f)
    dir_total=0
    for file in "${directory_files[@]}"; do
        file_count=$(wc "$mode_of_counting" <"$file")
        dir_total=$((dir_total + file_count))
    done
    if [[ dir_total -eq max_count ]]; then
        directories_with_max+=("$target_dir")
    fi
    if [[ dir_total -gt max_count ]]; then
        max_count=$dir_total
        directories_with_max=("$target_dir")
    fi
}
for directory in "${directories_to_search[@]}"; do
    max_count=-1
    directories_with_max=()
    analyze_directory "$directory"
    for max_dir in "${directories_with_max[@]}"; do
        echo "$max_dir" $max_count
    done
done
if [ "$missing_directory" -eq 1 ]; then
    exit 2
fi
exit 0
