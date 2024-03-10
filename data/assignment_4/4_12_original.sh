
maxDepth=0
folders=()
depthSet=0
while [ $# -gt 0 ]; do
    case "$1" in
        -h)
            echo 'Homework 4 (C)'
            echo ''
            echo 'Usage: script.sh [-h] [-d <depth>] [directory ...]'
            echo '-h: Show help'
            echo '-d <depth>: Define search depth as <depth> levels'
            exit 0
            ;;
        -d)
            if [ $depthSet -eq 1 ]; then
                echo "Error: Only one '-d' option is permitted" >&2
                exit 1
            fi
            shift
            if ! [[ $1 =~ ^[0-9]+$ ]] || [ $1 -lt 1 ]; then
                echo "Error: '-d' option needs a positive integer, received '$1'" >&2
                exit 1
            fi
            maxDepth=$1
            depthSet=1
            ;;
        *)
            if [ ! -e "$1" ]; then
                echo "Error: Directory '$1' does not exist" >&2
                exit 1
            fi
            if [ ! -d "$1" ]; then
                echo "Error: '$1' is not a valid directory" >&2
                exit 1
            fi
            folders+=("$1")
            ;;
    esac
    shift
done
if [ ${#folders[@]} -eq 0 ]; then
    folders+=("$(pwd)")
fi
linkResults=()
for folder in "${folders[@]}"; do
    if [ $maxDepth -eq 0 ]; then
        contents=$(find "$folder" -type d -exec ls -l {} \; 2>/dev/null)
    elif [ $maxDepth -eq 1 ]; then
        contents=$(ls -l "$folder" 2>/dev/null)
    else
        contents=$(find "$folder" -maxdepth $maxDepth -type d -exec ls -l {} \; 2>/dev/null)
    fi
    links=$(echo "$contents" | grep -e '->')
    if [ -n "$links" ]; then
        links=$(echo "$links" | awk '{print $(NF-2),$(NF-1), $NF}')
    fi
    mapfile -t extractedLinks <<<"$links"
    for link in "${extractedLinks[@]}"; do
        linkResults+=("$link")
    done
done
deepestLinks=()
deepestCount=-1
for link in "${linkResults[@]}"; do
    cleanLink=$(echo "$link" | grep -Eo '(->)(.*)')
    cleanLink=$(echo "$cleanLink" | tr -d "-> ")
    cleanLink=$(echo "$cleanLink" | grep -o "/")
    linkDepth=$(echo "$cleanLink" | wc -l)
    if [ $linkDepth -gt $deepestCount ]; then
        deepestCount=$linkDepth
        deepestLinks=()
        deepestLinks+=("$link")
    elif [ $linkDepth -eq $deepestCount ]; then
        deepestLinks+=("$link")
    fi
done
for link in "${deepestLinks[@]}"; do
    if [ -n "$link" ]; then
        echo "Deepest Link: '$link'"
    fi
done
exit 0
