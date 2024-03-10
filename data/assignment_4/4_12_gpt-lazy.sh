search_depth=0
input_paths=()
depth_defined=0
while [[ $# -gt 0 ]]; do
    if [[ $1 == "-h" ]]; then
        echo 'Homework 4 (C)'
        echo ''
        echo 'Usage: script.sh [-h] [-d <depth>] [path ...]'
        echo '-h: Show help'
        echo '-d <depth>: Search directories up to depth <depth> (inclusive)'
        exit 0
    elif [[ $1 == "-d" ]]; then
        if [[ $depth_defined -eq 1 ]]; then
            echo "Error: '-d' option specified multiple times" >&2
            exit 1
        fi
        shift
        if ! [[ $1 =~ ^[0-9]+$ ]] || [[ $1 -lt 1 ]]; then
            echo "Error: '-d' expects a positive integer, received '$1'" >&2
            exit 1
        fi
        search_depth="$1"
        depth_defined=1
    else
        if [ ! -e "$1" ]; then
            echo "Error: 'path $1 does not exist'" >&2
            exit 1
        fi
        if [ ! -d "$1" ]; then
            echo "Error: 'path $1 is not a directory'" >&2
            exit 1
        fi
        input_paths+=("$1")
    fi
    shift
done
if [[ ${#input_paths[@]} == 0 ]]; then
    input_paths+=("$(pwd)")
fi
found_links=()
for path in "${input_paths[@]}"; do
    if [[ $search_depth == 0 ]]; then
        files=$(find "$path" -type d -exec ls -l {} \; 2>/dev/null)
    elif [[ $search_depth == 1 ]]; then
        files=$(ls -l "$path" 2>/dev/null)
    else
        files=$(find "$path" -maxdepth "$search_depth" -type d -exec ls -l {} \; 2>/dev/null)
    fi
    links=$(echo "$files" | grep -e '->')
    if [[ -n $links ]]; then
        links=$(echo "$links" | awk '{print $(NF-2),$(NF-1), $NF}')
    fi
    mapfile -t split_links <<<"$links"
    for link in "${split_links[@]}"; do
        found_links+=("$link")
    done
done
largest_links=()
most_components=-1
for link in "${found_links[@]}"; do
    processed_link=$(echo "$link" | grep -Eo '(->)(.*)')
    processed_link=$(echo "$processed_link" | tr -d "\-\> ")
    processed_link=$(echo "$processed_link" | grep -o "/")
    current_components=$(echo "$processed_link" | wc -l)
    if [[ $current_components -gt $most_components ]]; then
        most_components=$current_components
        largest_links=()
        largest_links+=("$link")
    elif [[ $current_components == "$most_components" ]]; then
        largest_links+=("$link")
    fi
done
for link in "${largest_links[@]}"; do
    if [[ $link != "" ]]; then
        echo "Result: '$link'"
    fi
done
exit 0
