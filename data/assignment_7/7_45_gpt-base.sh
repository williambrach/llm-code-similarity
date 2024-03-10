
depthLimit=-1
initialDir=.
displayUsage() {
    echo "How to use: $0 [-h] [-d <depthLimit>] [path ...]"
    echo "Flags:"
    echo "  -h: Display this help text"
    echo "  -d <depthLimit>: Define how deep the search should go"
    echo "  path: Set the starting point(s) for the search"
    exit 0
}
while getopts "hd:" opt; do
    case $opt in
    h)
        displayUsage
        ;;
    d)
        depthLimit=$OPTARG
        ;;
    *)
        echo "Error: Unknown option provided" >&2
        exit 1
        ;;
    esac
done
shift $((OPTIND-1))
if [ $# -gt 0 ]; then
    initialDir="$@"
fi
searchFiles() {
    local baseDir="$1"
    local depth="$2"
    searchCmd="find $baseDir"
    if [ "$depth" -ne -1 ]; then
        searchCmd+=" -maxdepth $depth"
    fi
    searchCmd+=" -type f -print0"
    while IFS= read -r -d '' file; do
        fileBaseName=$(basename "$file")
        if grep -q -- "$fileBaseName" "$file"; then
            echo "Found: '$file $(grep -c -- "$fileBaseName" "$file")'"
        fi
    done < <(eval "$searchCmd")
    exit 0
}
searchFiles "$initialDir" "$depthLimit"
