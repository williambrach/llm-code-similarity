show_instructions() {
	echo >&1 -e "\nHomework1 (Bash)"
	echo >&1 "How to: Homework1.sh [-h] [-c] [-w] [directory(s) (optional)]"
	echo >&1 "This utility finds the folder(s) with the highest total"
	echo >&1 "number of lines in regular files. It searches the"
	echo >&1 "given directories or the current one if none are specified."
	echo >&1 ""
	echo >&1 "-h: displays this message"
	echo >&1 "-c: with this option, the utility counts"
	echo >&1 "    the total characters in files instead of lines."
	echo >&1 "-w: with this option, it counts"
	echo >&1 "    words in files instead of lines."
}
option="-l"
folders=()
while (("$#")); do
	case "$1" in
	-h)
		show_instructions
		exit 0
		;;
	-c)
		if [[ "$option" == "-w" ]]; then
			echo >&2 "Options -w and -c are mutually exclusive."
			echo >&2 "Refer to \"-h\" for help."
			exit 1
		else
			option="-c"
		fi
		;;
	-w)
		if [[ "$option" == "-c" ]]; then
			echo >&2 "Options -c and -w cannot be used together."
			echo >&2 "Refer to \"-h\" for help."
			exit 1
		else
			option="-w"
		fi
		;;
	-*)
		echo >&2 "Unrecognized option \"$1\""
		echo >&2 "Refer to \"-h\" for help."
		exit 1
		;;
	*)
		if [ ! -d "$1" ]; then
			echo >&2 "\"$1\" is not a valid directory."
			exit 1
		elif [ ! -r "$1" ]; then
			echo >&2 "\"$1\" cannot be read."
			exit 1
		else
			folders+=("$1")
		fi
		;;
	esac
	shift
done
if [[ "${#folders[@]}" == "0" ]]; then
	folders=(.)
fi
temporary_folders=()
for folder in "${folders[@]}"; do
	unset subfolders
	while IFS= read -r -d '' subfolder; do
		subfolders+=("$subfolder")
	done < <(find "$folder" -mindepth 1 -type d -print0)
	for subfolder in "${subfolders[@]}"; do
		if [[ ! -r "$subfolder" || ! -x "$subfolder" ]]; then
			echo >&2 "Error: '$folder': Access denied."
		else
			temporary_folders+=("$subfolder")
		fi
	done
done
for folder in "${temporary_folders[@]}"; do
	folders+=("$folder")
done
calculated_folders=()
for folder in "${folders[@]}"; do
	folder_count=0
	unset files
	for file in "$folder"/*; do
		if [ -f "$file" ]; then
			files+=("$file")
		fi
	done
	for file in "${files[@]}"; do
		if [ ! -r "$file" ]; then
			echo >&2 "Error: '$file': Access denied."
		else
			unset file_count
			file_count=$(wc "$option" "$file" 2>&1)
			if grep -q "wc:" <<<"$file_count"; then
				error=$(cut -d':' -f2- <<<"$file_count")
				echo >&2 "Error: $error"
			else
				file_count=$(awk '{print $1}' <<<"$file_count")
				folder_count=$((folder_count + file_count))
			fi
		fi
	done
	calculated_folders+=("$folder_count $folder")
done
mapfile -t calculated_folders < <(for folder in "${calculated_folders[@]}"; do echo "$folder"; done | sort -nr)
top_folder=top_folder=$(echo "${calculated_folders[@]}" | head -1)
max=$(echo "$top_folder" | cut -d' ' -f1)
for folder in "${calculated_folders[@]}"; do
	count=$(echo "$folder" | cut -d' ' -f1)
	directory=$(echo "$folder" | cut -d' ' -f2)
	if [[ $count -lt $max ]]; then
		break
	fi
	echo >&1 "Result: '$directory $count'"
done
