
declare -a directoriesWithCounts

display_help() {
    echo "usage_script.sh (C)
Usage: usage_script.sh [-h] [-c] [-w] [directory ...]
-h: Show Help
-c: Find directory/directories with the highest total character count in their files
-w: Find directory/directories with the highest total word count in their files"
    exit
}

if [[ $# -eq 1 && $1 == '-h' ]]; then
    display_help
elif [[ $# -eq 0 || ($# -eq 1 && { $1 == '-c' || $1 == '-w'; }) ]]; then
    readarray -t directoriesWithCounts < <(find . -type f | awk -F/ 'OFS="/"{$NF=""; print}' | uniq)
    optionIndex=2
else
    optionIndex=$([[ $1 == '-c' || $1 == '-w' ]] && echo 2 || echo 1)
fi

while [[ $optionIndex -le $# ]]; do
    if [[ -d "${!optionIndex}" ]]; then
        readarray -t directoriesWithCounts < <(find "${!optionIndex}" -type f | awk -F/ 'OFS="/"{$NF=""; print}' | uniq)
    else
        if [[ "${!optionIndex:0:1}" == '-' ]]; then
            echo "Error: Unsupported option '${!optionIndex}', use -h for help." >&2
        else
            echo "Error: Directory '${!optionIndex}' not found." >&2
        fi
        exit
    fi
    ((optionIndex++))
done

readarray -t directoriesWithCounts < <(printf '%s\n' "${directoriesWithCounts[@]}" | sort -u)
for index in "${!directoriesWithCounts[@]}"; do
    declare -a filesInDirectory
    total=0
    readarray -t filesInDirectory < <(find "${directoriesWithCounts[index]}" -maxdepth 1 -type f)
    for file in "${filesInDirectory[@]}"; do
        if [[ $1 == '-w' ]]; then
            ((total += $(wc -w <"$file")))
        elif [[ $1 == '-c' ]]; then
            ((total += $(wc -c <"$file")))
        else
            ((total += $(wc -l <"$file")))
        fi
    done
    directoriesWithCounts[index]+=" $total"
    unset filesInDirectory
done

highestTotal=$(printf '%s\n' "${directoriesWithCounts[@]}" | awk '{print $NF}' | sort -nr | head -n1)
printf '%s\n' "${directoriesWithCounts[@]}" | awk -v max="$highestTotal" '$NF == max {printf "Top: '\''%s %s'\''\n", $0}'
exit
