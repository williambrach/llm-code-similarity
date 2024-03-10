
display_usage() {
	echo "$0 (C)"
	echo ""
	echo "Usage: $0 [-h] [-d <level>] [directory ...]"
	echo "  -h: Display this help message"
	echo "  -d <level>: Specify search depth (default: 1)"
	echo "  [directory ...]: Directories to search"
}

search_depth='1'
search_dirs=()

while getopts ":hd:" option; do
	case $option in
		h)
			display_usage
			exit 0
			;;
		d)
			search_depth="$OPTARG"
			if ! [[ "$search_depth" =~ ^[1-9][0-9]*$ ]]; then
				echo "Error: Depth must be a positive integer." >&2
				exit 1
			fi
			;;
		:)
			echo "Error: Option '-$OPTARG' requires an argument." >&2
			exit 1
			;;
		\?)
			echo "Error: Invalid option. Use -h for help." >&2
			exit 1
			;;
	esac
done

shift $((OPTIND - 1))

while [ $# -gt 0 ]; do
	search_dirs+=("$1")
	shift
done

if [ "${#search_dirs[@]}" -eq 0 ]; then
	search_dirs=(".")
fi

found_files=()

for search_dir in "${search_dirs[@]}"; do
	if ! [[ -d "$search_dir" ]]; then
		echo "Error: $search_dir is not a valid directory" >&2
		exit 1
	fi
	original_IFS=$IFS
	IFS=$'\n'
	while IFS= read -r -d '' file_path; do
		if file "$file_path" | grep -q text && [ -r "$file_path" ]; then
			found_files+=("$file_path")
			file_basename=$(basename "$file_path")
			occurrences=$(grep -ce "$file_basename" "$file_path")
			if [[ $occurrences -gt 0 ]]; then
				echo "$(realpath "$file_path") $occurrences"
			fi
		fi
	done < <(find "$search_dir" -maxdepth "$search_depth" -type f -print0 2>&1)
	IFS=$original_IFS
done
