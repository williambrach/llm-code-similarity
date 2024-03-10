
show_help() {
    echo "Folder Content Analyzer"
    echo "How to use: analyze.sh [-h] [-w] [-m] [optional folder paths]"
    echo "Finds folders with the highest number of lines, words, or characters in text files"
    echo "-h shows this help info"
    echo "-w to count words instead"
    echo "-m to count characters instead"
}

log_debug() {
    if [[ -v debug_mode ]]; then echo -e "Debugging: $*"; fi
}

debug_mode=''
unset debug_mode
analysis_type="-l"
folders=()
selected_option=0

while (("$#")); do
    case "$1" in
    -h)
        show_help
        exit 0
        ;;
    -m)
        ((selected_option++))
        if ((selected_option > 1)); then
            echo "Cannot use -w and -m together. Refer to help (-h)."
            exit 0
        fi
        analysis_type="-m"
        ;;
    -w)
        ((selected_option++))
        if ((selected_option > 1)); then
            echo "Cannot use -w and -m together. Refer to help (-h)."
            exit 0
        fi
        analysis_type="-w"
        ;;
    -*)
        echo "Unrecognized option: $1"
        exit 0
        ;;
    *)
        if [[ ! -d "$1" || ! -r "$1" ]]; then
            echo "Cannot access $1 as a directory."
            exit 0
        fi
        folders+=("$1")
        ;;
    esac
    shift
done

if [[ "${#folders[@]}" == "0" ]]; then
    folders=(.)
fi

for folder in "${folders[@]}"; do
    while IFS= read -r -d '' nested_folder; do
        folders+=("$nested_folder")
    done < <(find "$folder" -mindepth 1 -type d -print0 2>&1)
done

folder_totals=()
for folder in "${folders[@]}"; do
    if [[ ! -r "$folder" ]]; then
        echo "Error: Cannot read directory '$folder'" 1>&2
        continue
    fi
    folder_sum=0
    while IFS= read -r -d '' file_path; do
        if [[ ! -r "$file_path" ]]; then
            echo "Error: Cannot read file '$file_path'" 1>&2
        else
            count=$(wc "$analysis_type" "$file_path" 2>&1)
            if [ $? -ne 0 ]; then
                echo "Error: wc failed on '$count'" 1>&2
            else
                count=$(awk '{print $1}' <<<"$count")
                folder_sum=$((folder_sum + count))
            fi
        fi
    done < <(find "$folder" -maxdepth 1 -type f -print0)
    folder_totals+=("$folder_sum $folder")
done

IFS=$'\n'
folder_totals=($(sort -nr <<<"${folder_totals[*]}"))
unset IFS

if [[ -v debug_mode ]]; then
    log_debug "Size of folder_totals: ${#folder_totals[@]}"
    for total in "${folder_totals[@]}"; do
        log_debug "Folder total: $total"
    done
fi

top=-1
for total in "${folder_totals[@]}"; do
    current_count=$(awk '{print $1}' <<<"$total")
    if [[ "$top" == "-1" ]]; then
        top=$current_count
    elif [[ $current_count -lt $top ]]; then
        break
    fi
    echo "$total" | awk '{print "Outcome: '\''" $2, $1 "'\''"}'
done
