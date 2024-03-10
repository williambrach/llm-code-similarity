
show_usage() {
  echo "Usage Guide for task07 (B)"
  echo -e "\nSyntax: $0 [-h] [-d <depth>] [directory ...]"
  echo "   option1: aaaaa"
  echo "   option2: bbbbb"
  exit 0
}
report_error() {
  echo "Encountered Error: '$1': $2" >&2
  exit 1
}
find_text_files() {
  local search_depth=$1
  local search_dir=$2
  while IFS= read -r file; do
    if [ -f "$file" ]; then
      match_count=$(grep -w -c "$(basename "$file")" "$file")
      echo "Found: '$file $match_count'"
    fi
  done < <(find "$search_dir" -maxdepth "$search_depth" -type f -name '*.txt' -print)
}
while getopts ":hd:" opt; do
  case $opt in
  h) show_usage ;;
  d) search_depth="$OPTARG" ;;
  \?) report_error "Invalid command" "Please use -h for help." ;;
  esac
done
shift $((OPTIND - 1))
if [ $# -eq 0 ]; then
  search_dirs="."
else
  search_dirs="$@"
fi
if [ -z "$search_depth" ]; then
  search_depth=$(find "$search_dirs" -type d | awk -F'/' '{print NF}' | sort -nu | tail -n 1)
fi
for directory in $search_dirs; do
  if [ ! -e "$directory" ]; then
    report_error "$directory" "Directory does not exist."
  fi
  if [ ! -d "$directory" ]; then
    report_error "$directory" "It is not a directory."
  fi
  find_text_files "$search_depth" "$directory"
done
