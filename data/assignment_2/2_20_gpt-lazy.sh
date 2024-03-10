assist() {
	echo "$0 (C)"
	echo ""
	echo "Usage: $0 -h directory ..."
	echo -e "\t-h: Display help message."
	echo -e "\t directory: Path to the file for processing."
}
search_longest_line() {
	longest=$(awk 'BEGIN{longest=0} longest<length{longest=length} END{print longest}' document.txt)
	awk -v x="$longest" -v f="-" 'x == length {gsub("\r", ""); printf "Result: '\''%s: %d %d %s'\''\n", f, NR, length, $0 }' document.txt
}
input_read() {
	rm document.txt 2>/dev/null #remove file if it existed
	IFS=$'\n'
	count=0
	while read -r line; do
		((count++))
		echo "$line" >>document.txt #reading line and saving to file
	done
	if [ "$count" -gt 0 ]; then
		search_longest_line
		rm document.txt
		exit 0
	else
		echo "Error: '-': no input provided" >&2
		exit 1
	fi
}
if [ $# == 0 ]; then
	input_read
else
	documents=()
	for arg in "$@"; do
		if [ "$arg" == "-h" ]; then
			assist
			exit 0
		elif [[ "$arg" == -* ]]; then
			echo "Error: '-': unknown option $arg" >&2
			exit 1
		else
			documents+=("$arg")
		fi
	done
	result=0
	for doc in "${documents[@]}"; do
		if [ -e "$doc" ]; then
			if [ -f "$doc" ]; then
				if [ -r "$doc" ]; then
					if file "$doc" | grep -q "text"; then
						continue
					elif file "$doc" | grep -q "empty"; then
						echo "Error: '$doc': file is empty" >&2
						result=1
						for i in "${!documents[@]}"; do
							if [[ ${documents[i]} = "$doc" ]]; then
								unset 'documents[i]'
							fi
						done
					else
						echo "Error: '$doc': file is not a text file" >&2
						result=1
						for i in "${!documents[@]}"; do
							if [[ ${documents[i]} = "$doc" ]]; then
								unset 'documents[i]'
							fi
						done
					fi
				else
					echo "Error: '$doc': file is not readable" >&2
					result=1
					for i in "${!documents[@]}"; do
						if [[ ${documents[i]} = "$doc" ]]; then
							unset 'documents[i]'
						fi
					done
				fi
			else
				echo "Error: '$doc': is not a text file" >&2
				result=1
				for i in "${!documents[@]}"; do
					if [[ ${documents[i]} = "$doc" ]]; then
						unset 'documents[i]'
					fi
				done
			fi
		else
			echo "Error: '$doc': file does not exist" >&2
			result=1
			for i in "${!documents[@]}"; do
				if [[ ${documents[i]} = "$doc" ]]; then
					unset 'documents[i]'
				fi
			done
		fi
	done
	if [ ${#documents[@]} -eq 0 ]; then
		exit 1
	fi
	longest=$(awk 'BEGIN{longest=0} longest<length{longest=length} END{print longest}' "${documents[@]}")
	for doc in "${documents[@]}"; do
		awk -v x="$longest" -v f="$doc" 'x == length {gsub("\r", ""); printf "Result: '\''%s: %d %d %s'\''\n", f, NR, length, $0 }' "$doc"
	done
fi
exit $result
