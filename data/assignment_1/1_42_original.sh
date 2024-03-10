
display_help() {
    echo >&1 -e "\nHow to Use This Script"
    echo >&1 "Format: script.sh [-h] [-c] [-w] [optional paths to directories]"
    echo >&1 "This utility calculates the directory(ies) with the greatest"
    echo >&1 "total number of lines in text files. It examines"
    echo >&1 "given directories or defaults to the present directory."
    echo >&1 ""
    echo >&1 "-h: displays help content"
    echo >&1 "-c: switches the script to count"
    echo >&1 "    the total number of characters instead of lines."
    echo >&1 "-w: this option counts"
    echo >&1 "    words in the files rather than lines."
}
counting_mode="-l"
directories_chosen=()
while (("$#")); do
    case "$1" in
    -h)
        display_help
        exit 0
        ;;
    -c)
        if [[ "$counting_mode" == "-w" ]]; then
            echo >&2 "Options -w and -c cannot be combined."
            echo >&2 "Refer to \"-h\" for help."
            exit 1
        else
            counting_mode="-c"
        fi
        ;;
    -w)
        if [[ "$counting_mode" == "-c" ]]; then
            echo >&2 "-c and -w options are mutually exclusive."
            echo >&2 "Refer to \"-h\" for help."
            exit 1
        else
            counting_mode="-w"
        fi
        ;;
    -*)
        echo >&2 "Unrecognized option \"$1\""
        echo >&2 "Refer to \"-h\" for help."
        exit 1
        ;;
    *)
        if [ ! -d "$1" ]; then
            echo >&2 "\"$1\" is not recognized as a directory."
            exit 1
        elif [ ! -r "$1" ]; then
            echo >&2 "\"$1\" cannot be accessed."
            exit 1
        else
            directories_chosen+=("$1")
        fi
        ;;
    esac
    shift
done
if [[ "${#directories_chosen[@]}" == "0" ]]; then
    directories_chosen=(.)
fi
all_directories=()
for directory in "${directories_chosen[@]}"; do
    unset subdirectories
    while IFS= read -r -d '' subdir; do
        subdirectories+=("$subdir")
    done < <(find "$directory" -mindepth 1 -type d -print0)
    for subdir in "${subdirectories[@]}"; do
        if [[ ! -r "$subdir" || ! -x "$subdir" ]]; then
            echo >&2 "Error: '$directory': Access denied."
        else
            all_directories+=("$subdir")
        fi
    done
done
for directory in "${all_directories[@]}"; do
    directories_chosen+=("$directory")
done
totals_per_dir=()
for directory in "${directories_chosen[@]}"; do
    total=0
    unset files
    for file in "$directory"/*; do
        if [ -f "$file" ]; then
            files+=("$file")
        fi
    done
    for file in "${files[@]}"; do
        if [ ! -r "$file" ]; then
            echo >&2 "Error: '$file': Access denied."
        else
            unset file_total
            file_total=$(wc "$counting_mode" "$file" 2>&1)
            if grep -q "wc:" <<<"$file_total"; then
                error=$(cut -d':' -f2- <<<"$file_total")
                echo >&2 "Error: $error"
            else
                file_total=$(awk '{print $1}' <<<"$file_total")
                total=$((total + file_total))
            fi
        fi
    done
    totals_per_dir+=("$total $directory")
done
mapfile -t ordered_totals < <(for total in "${totals_per_dir[@]}"; do echo "$total"; done | sort -nr)
highest_total=$(echo "${ordered_totals[0]}" | head -1)
highest_value=$(echo "$highest_total" | cut -d' ' -f1)
for total in "${ordered_totals[@]}"; do
    this_total=$(echo "$total" | cut -d' ' -f1)
    this_directory=$(echo "$total" | cut -d' ' -f2)
    if [[ $this_total -lt $highest_value ]]; then
        break
    fi
    echo >&1 "Result: '$this_directory $this_total'"
done
