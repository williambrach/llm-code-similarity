
display_help() {
	echo "execute_script.sh (C)"
	echo
	echo "Usage: execute_script.sh [-h] [-d <depth>] [directory ...]"
	echo "-h: Show help information"
	echo "-d: <depth>: Limit search to a specific depth"
	echo "directory: directories to search"
	echo
}

update_longest_link() {
	if [ "$1" -gt "${longest_link_length[0]}" ]; then
		longest_link_length=("$1")
		longest_link_name=("$2")
		full_path=("$(readlink -f "$2")")
	elif [ "$1" -eq "${longest_link_length[0]}" ]; then
		longest_link_length+=("$1")
		longest_link_name+=("$2")
		full_path+=("$(readlink -f "$2")")
	fi
}

count_path_parts() {
	local path="$1"
	local length=${#path}
	if [ "$length" -eq 1 ]; then
		echo "1"
	else
		echo "$path" | tr '/' '\n' | wc -l
	fi
}

print_results() {
	local total=${#longest_link_length[@]}
	if [ "${longest_link_length[0]}" -gt 0 ]; then
		for ((i = 0; i < "$total"; i++)); do
			echo "${longest_link_name[$i]}" '->' "${full_path[$i]}"
		done
	fi
}

search_depth=-1
if [ "$1" == "-h" ]; then
	display_help
	shift
fi
if [ "$1" == "-d" ]; then
	if [ "$2" -gt 0 ]; then
		search_depth="$2"
		shift 2
	else
		echo "Error: '$2': Depth must be a positive number" >&2
		exit 1
	fi
fi
input_dirs=("$@")
for dir in "${input_dirs[@]}"; do
	if ! [[ -d "$dir" ]]; then
		echo "Error: '$dir': No such directory" >&2
	else
		search_dirs+=("$dir")
	fi
done
if [ ${#input_dirs[@]} -eq 0 ]; then
	input_dirs=(".")
else
	input_dirs=("${search_dirs[@]}")
fi
longest_link_length=(0)
if [ ${#input_dirs[@]} -eq 0 ]; then
	exit 1
fi
for dir in "${input_dirs[@]}"; do
	if [ "$search_depth" -ne -1 ]; then
		while IFS= read -r -d '' file; do
			file_path=$(readlink -f "$file")
			part_count=$(count_path_parts "$file_path")
			if [ "$part_count" -ge "${longest_link_length[0]}" ]; then
				update_longest_link "$part_count" "$file"
			fi
		done < <(find "$dir" -maxdepth "$search_depth" -type l -print0)
	else
		while IFS= read -r -d '' file; do
			file_path=$(readlink -f "$file")
			part_count=$(count_path_parts "$file_path")
			if [ "$part_count" -ge "${longest_link_length[0]}" ]; then
				update_longest_link "$part_count" "$file"
			fi
		done < <(find "$dir" -type l -print0)
	fi
done
print_results
