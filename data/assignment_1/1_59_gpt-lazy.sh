show_instructions() {
        echo "task (C)"
        echo
        echo "Usage: <task.sh> <-h> <-c> <-w> <folder...>"
        echo "<-h>: Displays help"
        echo "<-c>: Counts characters instead of lines"
        echo "<-w>: Counts words instead of lines"
        echo "<folder...>: folders to search, defaults to current folder"
}
folders=()
count_mode=
error_folder_missing=0
for arg in "$@"; do
        if [ "$arg" = -h ]; then
                show_instructions
                exit 0
        elif [ "$arg" = -c ]; then
                if [ -n "$count_mode" ]; then
                        echo Error: only one of "-w" and "-c" can be specified >&2
                        exit 1
                fi
                count_mode=$arg
        elif [ "$arg" = -w ]; then
                if [ -n "$count_mode" ]; then
                        echo Error: only one of "-w" and "-c" can be specified >&2
                        exit 1
                fi
                count_mode=$arg
        elif [ "${arg:0:1}" = - ]; then
                echo Error: invalid option "$arg" >&2
                exit 1
        else
                folders+=("$arg")
        fi
done
if [ -z "$count_mode" ]; then
        count_mode=-l
fi
if [ ${#folders[@]} -eq 0 ]; then
        folders+=(".")
fi
process_directory() {
        local folder="$1"
        if ! find "$folder" 1>/dev/null 2>/dev/null; then
                echo Error: \'"$folder"\': folder does not exist >&2
                error_folder_missing=1
                return
        fi
        mapfile -t subfolders < <(find "$folder" -maxdepth 1 -type d ! -path "$folder")
        for subfolder in "${subfolders[@]}"; do
                process_directory "$subfolder"
        done
        mapfile -t files < <(find "$folder" -maxdepth 1 -type f)
        total_count=0
        for file in "${files[@]}"; do
                count=$(wc "$count_mode" <"$file")
                total_count=$((total_count + count))
        done
        if [[ total_count -eq highest_count ]]; then
                highest_count_folders+=("$folder")
        fi
        if [[ total_count -gt highest_count ]]; then
                highest_count=$total_count
                highest_count_folders=("$folder")
        fi
}
for folder in "${folders[@]}"; do
        highest_count=-1
        highest_count_folders=()
        process_directory "$folder"
        for highest_folder in "${highest_count_folders[@]}"; do
                echo "$highest_folder" $highest_count
        done
done
if [ "$error_folder_missing" -eq 1 ]; then
        exit 2
fi
exit 0
