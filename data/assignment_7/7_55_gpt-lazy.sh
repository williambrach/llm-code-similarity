show_instructions() {
  echo "task07 (B)"
  echo -e "\nHow to use: $0 [-h][-d <depth>] [path ...]"
  echo "   <param1>: aaaaa"
  echo "   <param2>: bbbbb"
  exit 0
}
report_error() {
  echo "Error encountered: '$1': $2" >&2
  exit 1
}
find_text_files() {
  local search_depth=$1
  local search_path=$2
  while IFS= read -r file; do
    if [ -f "$file" ]; then
      name_occurrences=$(grep -w -c "$(basename "$file")" "$file")
      echo "Result: '$file $name_occurrences'"
    fi
  done < <(find "$search_path" -type f -name '*.txt' -print)
}
while getopts ":hd:" opt; do
  case $opt in
  h) show_instructions ;;
  d) depth="$OPTARG" ;;
  \?) report_error "Invalid option" "Use -h for help." ;;
  esac
done
shift $((OPTIND - 1))
if [ $# -eq 0 ]; then
  search_paths="."
else
  search_paths="$@"
fi
if [ -z "$depth" ]; then
  depth=$(find "$search_paths" -type d | awk -F'/' '{print NF}' | sort -nu | tail -n 1)
fi
for path in $search_paths; do
  if [ ! -e "$path" ]; then
    report_error "$path" "Path does not exist."
  fi
  if [ ! -d "$path" ]; then
    report_error "$path" "Not a directory."
  fi
  find_text_files "$depth" "$path"
done
