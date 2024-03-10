
#!/bin/bash

display_usage() {
	cat >&2 <<EOF
Task07 (C) Modified
Usage: ${0} -h -d <depth> [folders]
  -d <depth>:       Define search depth (integer).
  -h:               Show help information.
  [folders]:        Space-separated list of folders to search.
EOF
}

execute_search() {
	find "$1" -maxdepth "$2" -type f | while IFS= read -r current_file; do
		file_name=$(basename "$current_file")
		if grep -q -- "$file_name" "$current_file"; then
			echo -n "$current_file "
			grep -c -- "$file_name" "$current_file"
		fi
	done
}

depth=1
directories=()

while [ "$#" -gt 0 ]; do
	case "$1" in
		-d)
			shift
			if [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -gt 0 ]; then
				depth="$1"
			else
				echo "Error: Invalid depth value '$1'. Must be a positive integer." >&2
				exit 1
			fi
			;;
		-h)
			display_usage
			exit 0
			;;
		-*)
			echo "Error: Unknown option '$1'." >&2
			exit 1
			;;
		*)
			directories+=("$1")
			;;
	esac
	shift
done

if [ ${#directories[@]} -eq 0 ]; then
	execute_search "." "$depth"
else
	for folder in "${directories[@]}"; do
		if [ -d "$folder" ]; then
			folder_path=$(realpath "$folder")
			execute_search "$folder_path" "$depth"
		else
			echo "Error: Directory '$folder' does not exist." >&2
			exit 1
		fi
	done
fi
