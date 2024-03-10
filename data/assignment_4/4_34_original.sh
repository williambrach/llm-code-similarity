
show_instructions() {
  echo "Program Name (C)"
  echo "How to use: $0 [-h] [-d <depth>] [directory ...]"
  echo "  -h: Show help information"
  echo "  -d <depth>: Specify search depth"
  echo "  directory: Directories to be searched"
}

depth_setting=""
while getopts ":hd:" opt; do
  case $opt in
  h) # Show help
    show_instructions
    exit 0
    ;;
  d) # Specify depth
    depth_setting=$OPTARG
    ;;
  \?)
    echo "Error: Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  :)
    echo "Error: Option -$OPTARG needs a value" >&2
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))
search_dirs=("$@")
if [ ${#search_dirs[@]} -eq 0 ]; then
  search_dirs=(".")
fi

max_depth=-1
deepest_links=()
for directory in "${search_dirs[@]}"; do
  if [ ! -d "$directory" ]; then
    echo "Error: '$directory' is not a directory" >&2
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
  done < <(find "$directory" -maxdepth "${depth_setting:-999}" -type l -print0)
done

for link in "${deepest_links[@]}"; do
  echo "Found: '$link'"
done

[[ ${#deepest_links[@]} -eq 0 ]] && echo "No symbolic links discovered."
