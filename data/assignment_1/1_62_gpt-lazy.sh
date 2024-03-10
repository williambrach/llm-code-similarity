assist_print() {
    echo "Task1 (C)"
    echo "Usage task1.sh [-h] [-w] [-m] [optional paths]"
    echo "Script searches directories, with highest total of lines in regular files"
    echo "-h displays help information"
    echo "-w with -w counts words instead of lines"
    echo "-m with -m counts characters instead of lines"
}
debug_log() {
    if [[ -v debug_mode ]]; then echo -e "Debug Info: $*"; fi
}
unset debug_mode
debug_mode=''
find_option="-l"
folders=()
counter=0
while (("$#")); do
    case "$1" in
    -h)
        assist_print
        exit 0
        ;;
    -m)
        ((counter++))
        if ((counter > 1)); then
            echo "Can only use -w or -m, not both. Refer to help (-h)."
            exit 0
        fi
        find_option="-m"
        ;;
    -w)
        ((counter++))
        if ((counter > 1)); then
            echo "Can only use -w or -m, not both. Refer to help (-h)."
            exit 0
        fi
        find_option="-w"
        ;;
    -*)
        echo "Unrecognized option: $1"
        exit 0
        ;;
    *)
        if [[ ! -d "$1" || ! -r "$1" ]]; then
            echo "$1 is either not a directory or not accessible."
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
length=${#folders[@]}
for ((i = 0; i < length; i++)); do
    folder="${folders[i]}"
    new_folders=()
    readarray -d$'\n' -t new_folders < <(find "$folder" -mindepth 1 -type d 2>&1)
    if [ $? -ne 0 ]; then
        echo "Error: '$folder': Unable to find subdirectories. " 1>&2
        continue
    fi
    for sub_folder in "${new_folders[@]}"; do
        folders+=("$sub_folder")
    done
done
results=()
for ((i = 0; i < ${#folders[@]}; i++)); do
    if [[ ! -r "${folders[i]}" ]]; then
        echo "Error: \'${folders[i]}\': Cannot be read" 1>&2
        continue
    fi
    unset file_list
    file_list=()
    folder_count=0
    readarray -d$'\n' -t file_list < <(find "${folders[i]}" -maxdepth 1 -type f)
    for ((k = 0; k < ${#file_list[@]}; k++)); do
        if [[ ! -r "${file_list[k]}" ]]; then
            echo "Error: \'${file_list[k]}\': Cannot be read" 1>&2
        else
            unset file_total
            file_total=$(wc "$find_option" "${file_list[k]}" 2>&1)
            if [ $? -ne 0 ]; then
                echo "Error: \'$file_total\': wc failed" 1>&2
            else
                file_total=$(awk '{print $1}' <<<"$file_total")
                folder_count=$((folder_count + file_total))
            fi
        fi
    done
    results+=("$folder_count ${folders[i]}")
done
IFS=$'\n'
results=($(printf "%s\n" "${results[@]}" | sort -nr))
unset IFS
if [[ -v debug_mode ]]; then
    debug_log "results size: ${#results[@]}"
    for result in "${results[@]}"; do
        debug_log "total count $result ."
    done
fi
top=-1
for ((i = 0; i < ${#results[@]}; i++)); do
    current=$(echo "${results[i]}" | cut -d ' ' -f1)
    if [[ "$top" == "-1" ]]; then
        top=$current
    elif [[ $current -lt $top ]]; then
        break
    fi
    awk -v result="${results[i]}" '{print "Result : '\''" $2, $1 "'\''"}' <<<"$result"
done
