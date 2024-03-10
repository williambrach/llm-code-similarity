
display_help() {
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
count_mode="-l"
directories=()
while (("$#")); do
    case "$1" in
    -h)
        display_help
        exit 0
        ;;
    -c)
        if [[ "$count_mode" == "-w" ]]; then
            echo >&2 "Cannot use -w and -c together."
            echo >&2 "See \"-h\" for usage information."
            exit 1
        else
            count_mode="-c"
        fi
        ;;
    -w)
        if [[ "$count_mode" == "-c" ]]; then
            echo >&2 "Cannot use -c and -w together."
            echo >&2 "See \"-h\" for usage information."
            exit 1
        else
            count_mode="-w"
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
            directories+=("$1")
        fi
        ;;
    esac
    shift
done
if [[ "${#directories[@]}" == "0" ]]; then
    directories=(.)
fi
temp_dirs=()
for dir in "${directories[@]}"; do
    unset child_dirs
    while IFS= read -r -d '' child_dir; do
        child_dirs+=("$child_dir")
    done < <(find "$dir" -mindepth 1 -type d -print0)
    for child_dir in "${child_dirs[@]}"; do
        if [[ ! -r "$child_dir" || ! -x "$child_dir" ]]; then
            echo >&2 "Error: '$dir': Permission denied."
        else
            temp_dirs+=("$child_dir")
        fi
    done
done
for dir in "${temp_dirs[@]}"; do
    directories+=("$dir")
done
dir_counts=()
for dir in "${directories[@]}"; do
    dir_total=0
    unset dir_files
    for file in "$dir"/*; do
        if [ -f "$file" ]; then
            dir_files+=("$file")
        fi
    done
    for file in "${dir_files[@]}"; do
        if [ ! -r "$file" ]; then
            echo >&2 "Error: '$file': Permission denied."
        else
            unset file_total
            file_total=$(wc "$count_mode" "$file" 2>&1)
            if grep -q "wc:" <<<"$file_total"; then
                error_message=$(cut -d':' -f2- <<<"$file_total")
                echo >&2 "Error: $error_message"
            else
                file_total=$(awk '{print $1}' <<<"$file_total")
                dir_total=$((dir_total + file_total))
            fi
        fi
    done
    dir_counts+=("$dir_total $dir")
done
mapfile -t dir_counts < <(for dir in "${dir_counts[@]}"; do echo "$dir"; done | sort -nr)
highest_count=$(echo "${dir_counts[0]}" | head -1)
highest=$(echo "$highest_count" | cut -d' ' -f1)
for dir in "${dir_counts[@]}"; do
    total=$(echo "$dir" | cut -d' ' -f1)
    path=$(echo "$dir" | cut -d' ' -f2)
    if [[ $total -lt $highest ]]; then
        break
    fi
    echo >&1 "Result: '$path $total'"
done
