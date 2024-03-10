
typeset -a dirsWithFiles
show_usage() {
    echo "usage_script.sh (C)
Usage: usage_script.sh [-h] [-c] [-w] [directory ...]
-h: Show Help
-c: Find directory/directories with the highest total character count in their files
-w: Find directory/directories with the highest total word count in their files"
    exit
}

if [[ $# -eq 1 && $1 == '-h' ]]; then
    show_usage
elif [[ $# -eq 0 || ($# -eq 1 && { $1 == '-c' || $1 == '-w'; }) ]]; then
    readarray -t dirsWithFiles < <(find . -type f | awk -F/ 'OFS="/"{$NF=""; print}' | uniq | sort)
    paramIndex=2
else
    paramIndex=$([[ $1 == '-c' || $1 == '-w' ]] && echo 2 || echo 1)
fi

while [[ $paramIndex -le $# ]]; do
    if [[ -d "${!paramIndex}" ]]; then
        readarray -t dirsWithFiles < <(find "${!paramIndex}" -type f | awk -F/ 'OFS="/"{$NF=""; print}' | uniq | sort)
    else
        if [[ "${!paramIndex:0:1}" == '-' ]]; then
            echo "Error: Unsupported option '${!paramIndex}', use -h for help." >&2
        else
            echo "Error: Directory '${!paramIndex}' not found." >&2
        fi
        exit
    fi
    ((paramIndex++))
done

readarray -t dirsWithFiles < <(printf '%s\n' "${dirsWithFiles[@]}" | sort -u)
for dirIndex in "${!dirsWithFiles[@]}"; do
    typeset -a filesInDir
    count=0
    readarray -t filesInDir < <(find "${dirsWithFiles[dirIndex]}" -maxdepth 1 -type f)
    for file in "${filesInDir[@]}"; do
        if [[ $1 == '-w' ]]; then
            ((count += $(wc -w <"$file")))
        elif [[ $1 == '-c' ]]; then
            ((count += $(wc -c <"$file")))
        else
            ((count += $(wc -l <"$file")))
        fi
    done
    dirsWithFiles[dirIndex]+=" $count"
    unset filesInDir
done

highestCount=$(printf '%s\n' "${dirsWithFiles[@]}" | awk '{print $NF}' | sort -nr | head -n1)
printf '%s\n' "${dirsWithFiles[@]}" | awk -v max="$highestCount" '$NF == max {printf "Top: '\''%s %s'\''\n", $0}'
exit
