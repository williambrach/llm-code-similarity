
show_usage() {
  echo "Application Title (C)"
  echo "How to use: $0 [-h] [-d <depth>] [path ...]"
  echo "  -h: Shows help information"
  echo "  -d <depth>: Defines how deep to search for links"
  echo "  path: Path(s) to perform the search"
}
depth_option=""
while getopts ":hd:" opt; do
  case $opt in
  h) # Show help
    show_usage
    exit 0
    ;;
  d) # Define search depth
    depth_option=$OPTARG
    ;;
  \?)
    echo "Error: 'Unknown option: -$OPTARG'" >&2
    exit 1
    ;;
  :)
    echo "Error: 'Option -$OPTARG needs a value'" >&2
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))
paths_to_search=("$@")
if [ ${#paths_to_search[@]} -eq 0 ]; then
  paths_to_search=(".")
fi
max_depth=-1
deepest_links=()
for path in "${paths_to_search[@]}"; do
  if [ ! -d "$path" ]; then
    echo "Error: '$path' is not a valid directory" >&2
    continue
  fi
  while IFS= read -r -d '' symlink; do
    target=$(readlink -f -- "$symlink")
    depth=$(echo "$target" | awk -F"/" '{print NF-1}')
    if [ "$depth" -gt $max_depth ]; then
      max_depth=$depth
      deepest_links=("$symlink -> $target")
    elif [ "$depth" -eq $max_depth ]; then
      deepest_links+=("$symlink -> $target")
    fi
  done < <(find "$path" -maxdepth "${depth_option:-999}" -type l -print0)
done
for link in "${deepest_links[@]}"; do
  echo "Result: '$link'"
done
[[ ${#deepest_links[@]} -eq 0 ]] && echo "No links found."
