
#!/bin/bash

print_help() {
	cat >&2 <<HELP
Task07 (C) Modified
Instructions: ${0} -h -d <depth> [directories]
  -d <depth>:       Set search depth (numeric).
  -h:               Display this help message.
  [directories]:    List of directories to search, separated by space.
HELP
}

search_files() {
	find "$1" -maxdepth "$2" -type f | while IFS= read -r file; do
		name=$(basename "$file")
		if grep -q -- "$name" "$file"; then
			echo -n "$file "
			grep -c -- "$name" "$file"
		fi
	done
}

search_depth=1
search_dirs=()

while [ "$#" -gt 0 ]; do
	case "$1" in
		-d)
			shift
			if [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -gt 0 ]; then
				search_depth="$1"
			else
				echo "Error: Depth '$1' is not a valid positive number." >&2
				exit 1
			fi
			;;
		-h)
			print_help
			exit 0
			;;
		-*)
			echo "Error: Unrecognized option '$1'." >&2
			exit 1
			;;
		*)
			search_dirs+=("$1")
			;;
	esac
	shift
done

if [ ${#search_dirs[@]} -eq 0 ]; then
	search_files "." "$search_depth"
else
	for dir in "${search_dirs[@]}"; do
		if [ -d "$dir" ]; then
			dir_path=$(realpath "$dir")
			search_files "$dir_path" "$search_depth"
		else
			echo "Error: '$dir' is not a valid directory." >&2
			exit 1
		fi
	done
fi
