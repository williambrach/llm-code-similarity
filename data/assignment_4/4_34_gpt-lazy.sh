display_help() {
  echo "Program Name (C)"
  echo "Usage: $0 [-h] [-l <level>] [directory ...]"
  echo "  -h: Displays this help message"
  echo "  -l <level>: Searches links up to a specified directory depth"
  echo "  directory: Directory/ies to search"
}
search_depth=""
while getopts ":hl:" option; do
  case ${option} in
  h) # Display help
    display_help
    exit 0
    ;;
  l) # Set search depth
    search_depth=$OPTARG
    ;;
  \?)
    echo "Error: 'Invalid option: -$OPTARG'" >&2
    exit 1
    ;;
  :)
    echo "Error: 'Option -$OPTARG requires an argument'" >&2
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))
directories_to_search=("$@")
if [ ${#directories_to_search[@]} -eq 0 ]; then
  directories_to_search=(".")
fi
longest_length=-1
longest_links=()
for directory in "${directories_to_search[@]}"; do
  if [ ! -d "$directory" ]; then
    echo "Error: '$directory': Not a directory" >&2
    continue
  fi
  while IFS= read -r -d '' link; do
    destination=$(readlink -f -- "$link")
    link_length=$(echo "$destination" | grep -o "/" | wc -l)
    if [ "$link_length" -gt $longest_length ]; then
      longest_length=$link_length
      longest_links=("$link -> $destination")
    elif [ "$link_length" -eq "$longest_length" ]; then
      longest_links+=("$link -> $destination")
    fi
  done < <(find "$directory" -maxdepth "${search_depth:-999}" -type l -print0)
done
for link in "${longest_links[@]}"; do
  echo "Output: '$link'"
done
[[ ${#longest_links[@]} -eq 0 ]] && echo "No symbolic links were found."
