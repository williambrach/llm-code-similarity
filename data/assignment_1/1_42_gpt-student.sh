
show_usage() {
    echo >&1 -e "\nUsage Guide for Script"
    echo >&1 "Syntax: script.sh [-h] [-c] [-w] [optional directory paths]"
    echo >&1 "This script identifies the directory(ies) with the highest"
    echo >&1 "sum of lines in regular files. It scans"
    echo >&1 "specified directories or the current directory by default."
    echo >&1 ""
    echo >&1 "-h: shows this help information"
    echo >&1 "-c: this flag makes the script count"
    echo >&1 "    total characters in files instead of lines."
    echo >&1 "-w: this flag changes the count to"
    echo >&1 "    words in files instead of lines."
}
count_option="-l"
selected_dirs=()
while (("$#")); do
    case "$1" in
    -h)
        show_usage
        exit 0
        ;;
    -c)
        if [[ "$count_option" == "-w" ]]; then
            echo >&2 "Cannot use -w and -c together."
            echo >&2 "See \"-h\" for usage information."
            exit 1
        else
            count_option="-c"
        fi
        ;;
    -w)
        if [[ "$count_option" == "-c" ]]; then
            echo >&2 "Cannot use -c and -w together."
            echo >&2 "See \"-h\" for usage information."
            exit 1
        else
            count_option="-w"
        fi
        ;;
    -*)
        echo >&2 "Unknown option \"$1\""
        echo >&2 "See \"-h\" for usage information."
        exit 1
        ;;
    *)
        if [ ! -d "$1" ]; then
            echo >&2 "\"$1\" is not a directory."
            exit 1
        elif [ ! -r "$1" ]; then
            echo >&2 "Cannot read \"$1\"."
            exit 1
        else
            selected_dirs+=("$1")
        fi
        ;;
    esac
    shift
done
if [[ "${#selected_dirs[@]}" == "0" ]]; then
    selected_dirs=(.)
fi
all_dirs=()
for dir in "${selected_dirs[@]}"; do
    unset sub_dirs
    while IFS= read -r -d '' sub_dir; do
        sub_dirs+=("$sub_dir")
    done < <(find "$dir" -mindepth 1 -type d -print0)
    for sub_dir in "${sub_dirs[@]}"; do
        if [[ ! -r "$sub_dir" || ! -x "$sub_dir" ]]; then
            echo >&2 "Error: '$dir': Permission denied."
        else
            all_dirs+=("$sub_dir")
        fi
    done
done
for dir in "${all_dirs[@]}"; do
    selected_dirs+=("$dir")
done
dir_totals=()
for dir in "${selected_dirs[@]}"; do
    total_in_dir=0
    unset files_in_dir
    for file in "$dir"/*; do
        if [ -f "$file" ]; then
            files_in_dir+=("$file")
        fi
    done
    for file in "${files_in_dir[@]}"; do
        if [ ! -r "$file" ]; then
            echo >&2 "Error: '$file': Permission denied."
        else
            unset total_in_file
            total_in_file=$(wc "$count_option" "$file" 2>&1)
            if grep -q "wc:" <<<"$total_in_file"; then
                error_message=$(cut -d':' -f2- <<<"$total_in_file")
                echo >&2 "Error: $error_message"
            else
                total_in_file=$(awk '{print $1}' <<<"$total_in_file")
                total_in_dir=$((total_in_dir + total_in_file))
            fi
        fi
    done
    dir_totals+=("$total_in_dir $dir")
done
mapfile -t sorted_totals < <(for total in "${dir_totals[@]}"; do echo "$total"; done | sort -nr)
top_total=$(echo "${sorted_totals[0]}" | head -1)
top_value=$(echo "$top_total" | cut -d' ' -f1)
for total in "${sorted_totals[@]}"; do
    current_total=$(echo "$total" | cut -d' ' -f1)
    current_path=$(echo "$total" | cut -d' ' -f2)
    if [[ $current_total -lt $top_value ]]; then
        break
    fi
    echo >&1 "Result: '$current_path $current_total'"
done
