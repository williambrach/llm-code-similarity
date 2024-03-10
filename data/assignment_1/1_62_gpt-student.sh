
display_usage() {
    echo "Directory Analyzer"
    echo "Usage: analyzer.sh [-h] [-w] [-m] [optional directories]"
    echo "Identifies directories with the highest count of lines, words, or characters in text files"
    echo "-h displays this help message"
    echo "-w with -w option, counts words instead"
    echo "-m with -m option, counts characters instead"
}

debug_log() {
    if [[ -v debug ]]; then echo -e "Debug: $*"; fi
}

unset debug
debug=''
count_mode="-l"
directories=()
option_count=0

while (("$#")); do
    case "$1" in
    -h)
        display_usage
        exit 0
        ;;
    -m)
        ((option_count++))
        if ((option_count > 1)); then
            echo "Options -w and -m are mutually exclusive. See help (-h)."
            exit 0
        fi
        count_mode="-m"
        ;;
    -w)
        ((option_count++))
        if ((option_count > 1)); then
            echo "Options -w and -m are mutually exclusive. See help (-h)."
            exit 0
        fi
        count_mode="-w"
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
        directories+=("$1")
        ;;
    esac
    shift
done

if [[ "${#directories[@]}" == "0" ]]; then
    directories=(.)
fi

for dir in "${directories[@]}"; do
    while IFS= read -r -d '' sub_dir; do
        directories+=("$sub_dir")
    done < <(find "$dir" -mindepth 1 -type d -print0 2>&1)
done

totals=()
for dir in "${directories[@]}"; do
    if [[ ! -r "$dir" ]]; then
        echo "Error: '$dir': Directory unreadable" 1>&2
        continue
    fi
    dir_total=0
    while IFS= read -r -d '' file; do
        if [[ ! -r "$file" ]]; then
            echo "Error: '$file': File unreadable" 1>&2
        else
            total=$(wc "$count_mode" "$file" 2>&1)
            if [ $? -ne 0 ]; then
                echo "Error: '$total': wc command failed" 1>&2
            else
                total=$(awk '{print $1}' <<<"$total")
                dir_total=$((dir_total + total))
            fi
        fi
    done < <(find "$dir" -maxdepth 1 -type f -print0)
    totals+=("$dir_total $dir")
done

IFS=$'\n'
totals=($(sort -nr <<<"${totals[*]}"))
unset IFS

if [[ -v debug ]]; then
    debug_log "totals size: ${#totals[@]}"
    for total in "${totals[@]}"; do
        debug_log "total: $total"
    done
fi

highest=-1
for total in "${totals[@]}"; do
    current=$(awk '{print $1}' <<<"$total")
    if [[ "$highest" == "-1" ]]; then
        highest=$current
    elif [[ $current -lt $highest ]]; then
        break
    fi
    echo "$total" | awk '{print "Result: '\''" $2, $1 "'\''"}'
done
