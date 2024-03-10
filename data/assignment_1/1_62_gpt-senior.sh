
show_help() {
    echo "Task1 (C)"
    echo "How to use: task1.sh [-h] [-w] [-m] [optional directories]"
    echo "Finds directories with the highest count of lines in text files"
    echo "-h shows this help message"
    echo "-w with -w option, counts words instead"
    echo "-m with -m option, counts characters instead"
}
log_debug() {
    if [[ -v debug ]]; then echo -e "Debug: $*"; fi
}
unset debug
debug=''
search_mode="-l"
dirs=()
opt_count=0
while (("$#")); do
    case "$1" in
    -h)
        show_help
        exit 0
        ;;
    -m)
        ((opt_count++))
        if ((opt_count > 1)); then
            echo "Options -w and -m are mutually exclusive. See help (-h)."
            exit 0
        fi
        search_mode="-m"
        ;;
    -w)
        ((opt_count++))
        if ((opt_count > 1)); then
            echo "Options -w and -m are mutually exclusive. See help (-h)."
            exit 0
        fi
        search_mode="-w"
        ;;
    -*)
        echo "Option not recognized: $1"
        exit 0
        ;;
    *)
        if [[ ! -d "$1" || ! -r "$1" ]]; then
            echo "The path $1 is not a directory or cannot be accessed."
            exit 0
        fi
        dirs+=("$1")
        ;;
    esac
    shift
done
if [[ "${#dirs[@]}" == "0" ]]; then
    dirs=(.)
fi
dir_count=${#dirs[@]}
for ((i = 0; i < dir_count; i++)); do
    dir="${dirs[i]}"
    new_dirs=()
    readarray -d$'\n' -t new_dirs < <(find "$dir" -mindepth 1 -type d 2>&1)
    if [ $? -ne 0 ]; then
        echo "Error accessing '$dir': Cannot find subdirectories." 1>&2
        continue
    fi
    for new_dir in "${new_dirs[@]}"; do
        dirs+=("$new_dir")
    done
done
totals=()
for dir in "${dirs[@]}"; do
    if [[ ! -r "$dir" ]]; then
        echo "Error: '$dir': Directory unreadable" 1>&2
        continue
    fi
    unset files
    files=()
    dir_total=0
    readarray -d$'\n' -t files < <(find "$dir" -maxdepth 1 -type f)
    for file in "${files[@]}"; do
        if [[ ! -r "$file" ]]; then
            echo "Error: '$file': File unreadable" 1>&2
        else
            unset total
            total=$(wc "$search_mode" "$file" 2>&1)
            if [ $? -ne 0 ]; then
                echo "Error: '$total': wc command failed" 1>&2
            else
                total=$(awk '{print $1}' <<<"$total")
                dir_total=$((dir_total + total))
            fi
        fi
    done
    totals+=("$dir_total $dir")
done
IFS=$'\n'
totals=($(printf "%s\n" "${totals[@]}" | sort -nr))
unset IFS
if [[ -v debug ]]; then
    log_debug "totals size: ${#totals[@]}"
    for total in "${totals[@]}"; do
        log_debug "total: $total"
    done
fi
highest=-1
for total in "${totals[@]}"; do
    current=$(echo "$total" | cut -d ' ' -f1)
    if [[ "$highest" == "-1" ]]; then
        highest=$current
    elif [[ $current -lt $highest ]]; then
        break
    fi
    awk -v total="$total" '{print "Result: '\''" $2, $1 "'\''"}' <<<"$total"
done
