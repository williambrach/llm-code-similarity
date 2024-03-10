
#!/bin/bash

show_help() {
	cat >&2 <<END
Task07 (C) Modified
How to use: ${0} -h -d <level> [directories]
  -d <level>:      Set search depth (integer).
  -h:              Display help information.
  [directories]:   Space-separated list of directories to search.
END
}

perform_search() {
	find "$1" -maxdepth "$2" -type f | while IFS= read -r file; do
		file_name=$(basename "$file")
		if grep -q -- "$file_name" "$file"; then
			echo -n "$file "
			grep -c -- "$file_name" "$file"
		fi
	done
}

search_depth=1
paths=()

while [ "$#" -gt 0 ]; do
	case "$1" in
		-d)
			shift
			if [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -gt 0 ]; then
				search_depth="$1"
			else
				echo "Error: Invalid depth value '$1'. Must be a positive integer." >&2
				exit 1
			fi
			;;
		-h)
			show_help
			exit 0
			;;
		-*)
			echo "Error: Unknown option '$1'." >&2
			exit 1
			;;
		*)
			paths+=("$1")
			;;
	esac
	shift
done

if [ ${#paths[@]} -eq 0 ]; then
	perform_search "." "$search_depth"
else
	for dir in "${paths[@]}"; do
		if [ -d "$dir" ]; then
			dir_abs=$(realpath "$dir")
			perform_search "$dir_abs" "$search_depth"
		else
			echo "Error: Directory '$dir' does not exist." >&2
			exit 1
		fi
	done
fi
