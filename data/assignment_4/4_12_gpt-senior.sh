
max_depth=0
paths_list=()
depth_set=0
while [ $# -gt 0 ]; do
    case $1 in
        -h)
            echo 'Assignment 4 (C)'
            echo ''
            echo 'Syntax: myscript.sh [-h] [-d <depth>] [directory ...]'
            echo '-h: Display help'
            echo '-d <depth>: Limit directory search to <depth> levels'
            exit 0
            ;;
        -d)
            if [ $depth_set -eq 1 ]; then
                echo "Error: Multiple '-d' options not allowed" >&2
                exit 1
            fi
            shift
            if ! [[ $1 =~ ^[0-9]+$ ]] || [ $1 -lt 1 ]; then
                echo "Error: '-d' requires a positive integer, got '$1'" >&2
                exit 1
            fi
            max_depth=$1
            depth_set=1
            ;;
        *)
            if [ ! -e "$1" ]; then
                echo "Error: Path '$1' does not exist" >&2
                exit 1
            fi
            if [ ! -d "$1" ]; then
                echo "Error: Path '$1' is not a directory" >&2
                exit 1
            fi
            paths_list+=("$1")
            ;;
    esac
    shift
done
if [ ${#paths_list[@]} -eq 0 ]; then
    paths_list+=("$(pwd)")
fi
discovered_links=()
for dir in "${paths_list[@]}"; do
    if [ $max_depth -eq 0 ]; then
        dir_files=$(find "$dir" -type d -exec ls -l {} \; 2>/dev/null)
    elif [ $max_depth -eq 1 ]; then
        dir_files=$(ls -l "$dir" 2>/dev/null)
    else
        dir_files=$(find "$dir" -maxdepth $max_depth -type d -exec ls -l {} \; 2>/dev/null)
    fi
    sym_links=$(echo "$dir_files" | grep -e '->')
    if [ -n "$sym_links" ]; then
        sym_links=$(echo "$sym_links" | awk '{print $(NF-2),$(NF-1), $NF}')
    fi
    mapfile -t parsed_links <<<"$sym_links"
    for slink in "${parsed_links[@]}"; do
        discovered_links+=("$slink")
    done
done
extensive_links=()
highest_count=-1
for slink in "${discovered_links[@]}"; do
    mod_link=$(echo "$slink" | grep -Eo '(->)(.*)')
    mod_link=$(echo "$mod_link" | tr -d "-> ")
    mod_link=$(echo "$mod_link" | grep -o "/")
    link_count=$(echo "$mod_link" | wc -l)
    if [ $link_count -gt $highest_count ]; then
        highest_count=$link_count
        extensive_links=()
        extensive_links+=("$slink")
    elif [ $link_count -eq $highest_count ]; then
        extensive_links+=("$slink")
    fi
done
for slink in "${extensive_links[@]}"; do
    if [ -n "$slink" ]; then
        echo "Result: '$slink'"
    fi
done
exit 0
