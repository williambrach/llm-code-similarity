declare -a foldersWithContent
if [[ $# -eq 1 && $1 = '-h' ]]; then
        echo 'assignment.sh (C)
Usage: assignment.sh [-h] [-c] [-w] [path ...]
-h: Display Help
-c: Identify directory/directories with the largest total number of characters in direct regular files
-w: Identify directory/directories with the largest total number of words in direct regular files'
        exit
elif [[ $# -eq 0 || ($# -eq 1 && ($1 = '-w' || $1 = '-c')) ]]; then
        mapfile -t foldersWithContent < <(find . -type f | rev | cut -d '/' -f 2- | rev | sort | uniq) #Retrieve all directories from current directory containing any regular files
        currentParam=2
else
        if [[ $1 = '-w' || $1 = '-c' ]]; then
                currentParam=2
        else
                currentParam=1
        fi
fi
for ((currentParam; currentParam < $# + 1; currentParam++)); do
        if [[ -d "${!currentParam}" ]]; then
                mapfile -t foldersWithContent < <(find "${!currentParam}" -type f | rev | cut -d '/' -f 2- | rev | sort | uniq)
        else
                if [[ "${!currentParam:0:1}" == '-' ]]; then
                        echo "Error: '${!currentParam}': Unsupported option, use -h for all possible options." >&2
                else
                        echo "Error: '${!currentParam}': Directory does not exist." >&2
                fi
                exit
        fi
done
mapfile -t foldersWithContent < <(echo "${foldersWithContent[*]}" | tr ' ' '\n' | sort -u)
for ((currentFolder = 0; currentFolder < ${#foldersWithContent[@]}; currentFolder++)); do
        declare -a directFiles
        tally=0
        mapfile -t directFiles < <(find "${foldersWithContent[$currentFolder]}" -maxdepth 1 -type f)
        for currentFile in "${directFiles[@]}"; do
                if [[ $1 = '-w' ]]; then
                        tally=$((tally + $(wc -w <"$currentFile")))
                elif [[ $1 = '-c' ]]; then
                        tally=$((tally + $(wc -c <"$currentFile")))
                else
                        tally=$((tally + $(wc -l <"$currentFile")))
                fi
        done
        foldersWithContent["$currentFolder"]="${foldersWithContent[$currentFolder]} $tally"
        unset directFiles
done
topScore=$(echo "${foldersWithContent[@]}" | tr ' ' '\n' | awk 'NR % 2 == 0' | sort -n | tail -n -1)
echo "${foldersWithContent[@]}" | awk '{ for (i = 1; i <= NF; i += 2) print $i, $(i+1) }' | awk -v topScore="$topScore" 'topScore == $2 {printf "Result: '\''%s %s'\''\n", $1, $2}'
exit
