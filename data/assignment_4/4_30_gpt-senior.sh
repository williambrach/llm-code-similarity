
help_guide() {
	echo "execute_script.sh (C)"
	echo
	echo "Usage: execute_script.sh [-h] [-d <depth>] [directory ...]"
	echo "-h: Show help information"
	echo "-d: <depth>: Limit search to a specific depth"
	echo "directory: directories to search"
	echo
}

update_max_link() {
	if [ "$1" -gt "${max_link_length[0]}" ]; then
		max_link_length=("$1")
		max_link=("$2")
		longest_path=("$(readlink -f "$2")")
	elif [ "$1" -eq "${max_link_length[0]}" ]; then
		max_link_length+=("$1")
		max_link+=("$2")
		longest_path+=("$(readlink -f "$2")")
	fi
}

calculate_parts() {
	path="$1"
	length=${#path}
	if [ "$length" -eq 1 ]; then
		echo "1"
	else
		echo "$path" | tr '/' '\n' | wc -l
	fi
}

show_results() {
	total=${#max_link_length[@]}
	if [ "${max_link_length[0]}" -gt 0 ]; then
		for ((i = 0; i < "$total"; i++)); do
			echo "${max_link[$i]}" '->' "${longest_path[$i]}"
		done
	fi
}

depth_limit=-1
if [ "$1" == "-h" ]; then
	help_guide
	shift
fi
if [ "$1" == "-d" ]; then
	if [ "$2" -gt 0 ]; then
		depth_limit="$2"
		shift 2
	else
		echo "Error: '$2': Depth must be a positive number" >&2
		exit 1
	fi
fi
directories=("$@")
for dir in "${directories[@]}"; do
	if ! [[ -d "$dir" ]]; then
		echo "Error: '$dir': No such directory" >&2
	else
		valid_directories+=("$dir")
	fi
done
if [ ${#directories[@]} -eq 0 ]; then
	directories=(".")
else
	directories=("${valid_directories[@]}")
fi
max_link_length=(0)
if [ ${#directories[@]} -eq 0 ]; then
	exit 1
fi
for dir in "${directories[@]}"; do
	if [ "$depth_limit" -ne -1 ]; then
		while IFS= read -r -d '' file; do
			file_path=$(readlink -f "$file")
			part_count=$(calculate_parts "$file_path")
			if [ "$part_count" -ge "${max_link_length[0]}" ]; then
				update_max_link "$part_count" "$file"
			fi
		done < <(find "$dir" -maxdepth "$depth_limit" -type l -print0)
	else
		while IFS= read -r -d '' file; do
			file_path=$(readlink -f "$file")
			part_count=$(calculate_parts "$file_path")
			if [ "$part_count" -ge "${max_link_length[0]}" ]; then
				update_max_link "$part_count" "$file"
			fi
		done < <(find "$dir" -type l -print0)
	fi
done
show_results
