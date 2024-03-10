
maxDepth=-1
rootDir=.
showHelp() {
    echo "Usage: $0 [-h] [-m <maxDepth>] [directory ...]"
    echo "Options:"
    echo "  -h: Show this help message"
    echo "  -m <maxDepth>: Set the maximum depth for directory search"
    echo "  directory: Specify the root directories for the search"
    exit 0
}
while getopts "hm:" option; do
    case $option in
    h)
        showHelp
        ;;
    m)
        maxDepth=$OPTARG
        ;;
    *)
        echo "Error: Invalid command option" >&2
        exit 1
        ;;
    esac
done
shift $((OPTIND-1))
if [ $# -ne 0 ]; then
    rootDir="$@"
fi
findFiles() {
    local searchDir="$1"
    local depthLimit="$2"
    findCommand="find $searchDir"
    if [ "$depthLimit" -ne -1 ]; then
        findCommand+=" -maxdepth $depthLimit"
    fi
    findCommand+=" -type f -print0"
    while IFS= read -r -d '' filePath; do
        fileName=$(basename "$filePath")
        if grep -q -- "$fileName" "$filePath"; then
            echo "Match: '$filePath $(grep -c -- "$fileName" "$filePath")'"
        fi
    done < <(eval "$findCommand")
    exit 0
}
findFiles "$rootDir" "$maxDepth"
