
# Initialize an array to hold directories and their counts
declare -a dirsWithTotals

# Function to display script usage
show_usage() {
    echo "script_usage.sh (C)
Usage: script_usage.sh [-h] [-c] [-w] [directory ...]
-h: Display this help message
-c: Identify the directory/directories with the largest total number of characters in files
-w: Identify the directory/directories with the largest total number of words in files"
    exit
}

# Handle command line arguments
if [[ $# -eq 1 && $1 == '-h' ]]; then
    show_usage
elif [[ $# -eq 0 || ($# -eq 1 && { $1 == '-c' || $1 == '-w'; }) ]]; then
    readarray -t dirsWithTotals < <(find . -type f | awk -F/ 'OFS="/"{$NF=""; print}' | uniq)
    argPos=2
else
    argPos=$([[ $1 == '-c' || $1 == '-w' ]] && echo 2 || echo 1)
fi

# Process directories
while [[ $argPos -le $# ]]; do
    if [[ -d "${!argPos}" ]]; then
        readarray -t dirsWithTotals < <(find "${!argPos}" -type f | awk -F/ 'OFS="/"{$NF=""; print}' | uniq)
    else
        if [[ "${!argPos:0:1}" == '-' ]]; then
            echo "Error: Unsupported flag '${!argPos}', use -h for help." >&2
        else
            echo "Error: Cannot find directory '${!argPos}'." >&2
        fi
        exit
    fi
    ((argPos++))
done

# Remove duplicate directories
readarray -t dirsWithTotals < <(printf '%s\n' "${dirsWithTotals[@]}" | sort -u)
# Calculate totals for each directory
for idx in "${!dirsWithTotals[@]}"; do
    declare -a filesInDir
    sum=0
    readarray -t filesInDir < <(find "${dirsWithTotals[idx]}" -maxdepth 1 -type f)
    for file in "${filesInDir[@]}"; do
        if [[ $1 == '-w' ]]; then
            ((sum += $(wc -w <"$file")))
        elif [[ $1 == '-c' ]]; then
            ((sum += $(wc -c <"$file")))
        else
            ((sum += $(wc -l <"$file")))
        fi
    done
    dirsWithTotals[idx]+=" $sum"
    unset filesInDir
done

# Find and display the highest total
maxTotal=$(printf '%s\n' "${dirsWithTotals[@]}" | awk '{print $NF}' | sort -nr | head -n1)
printf '%s\n' "${dirsWithTotals[@]}" | awk -v max="$maxTotal" '$NF == max {printf "Top: '\''%s %s'\''\n", $0}'
exit
