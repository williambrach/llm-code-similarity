
searchDepth=0
directoryList=()
depthFlag=0
while [ $# -gt 0 ]; do
    case $1 in
        -h)
            echo 'Assignment 4 (C)'
            echo ''
            echo 'Syntax: myscript.sh [-h] [-d <depth>] [directory ...]'
            echo '-h: Display help'
            echo '-d <depth>: Set search depth to <depth> levels'
            exit 0
            ;;
        -d)
            if [ $depthFlag -eq 1 ]; then
                echo "Error: Multiple '-d' options not allowed" >&2
                exit 1
            fi
            shift
            if ! [[ $1 =~ ^[0-9]+$ ]] || [ $1 -lt 1 ]; then
                echo "Error: '-d' requires a positive integer, got '$1'" >&2
                exit 1
            fi
            searchDepth=$1
            depthFlag=1
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
            directoryList+=("$1")
            ;;
    esac
    shift
done
if [ ${#directoryList[@]} -eq 0 ]; then
    directoryList+=("$(pwd)")
fi
foundLinks=()
for dir in "${directoryList[@]}"; do
    if [ $searchDepth -eq 0 ]; then
        dirContents=$(find "$dir" -type d -exec ls -l {} \; 2>/dev/null)
    elif [ $searchDepth -eq 1 ]; then
        dirContents=$(ls -l "$dir" 2>/dev/null)
    else
        dirContents=$(find "$dir" -maxdepth $searchDepth -type d -exec ls -l {} \; 2>/dev/null)
    fi
    symLinks=$(echo "$dirContents" | grep -e '->')
    if [ -n "$symLinks" ]; then
        symLinks=$(echo "$symLinks" | awk '{print $(NF-2),$(NF-1), $NF}')
    fi
    mapfile -t parsedLinks <<<"$symLinks"
    for link in "${parsedLinks[@]}"; do
        foundLinks+=("$link")
    done
done
longestLinks=()
maxCount=-1
for link in "${foundLinks[@]}"; do
    modifiedLink=$(echo "$link" | grep -Eo '(->)(.*)')
    modifiedLink=$(echo "$modifiedLink" | tr -d "-> ")
    modifiedLink=$(echo "$modifiedLink" | grep -o "/")
    count=$(echo "$modifiedLink" | wc -l)
    if [ $count -gt $maxCount ]; then
        maxCount=$count
        longestLinks=()
        longestLinks+=("$link")
    elif [ $count -eq $maxCount ]; then
        longestLinks+=("$link")
    fi
done
for link in "${longestLinks[@]}"; do
    if [ -n "$link" ]; then
        echo "Result: '$link'"
    fi
done
exit 0
