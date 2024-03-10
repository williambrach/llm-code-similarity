
pomoc() {
	echo "Úloha 7 - vyhľadávač výskytov mien (C)"
	echo ""
	echo "Použitie: $0 <-h> <-d (hĺbka)> <cesta>"
	echo "<-h>: vypíše pomocnú správu resp. túto správu"
	echo "<-d>: nastaví hĺbku hľadania, nasledovaný prirodzeným číslom N"
	echo "<cesta>: cesta do adresára, kde sa spustí hľadanie"
}
súbory=()
pridaj_súbory() {
	local adresár="$1"
	if grep -qE "^find: .*" <<<"$adresár"; then
		echo "Chyba find" 1>&2
		exit 1
	else
		if file "$adresár" | grep -qi "text"; then
			if [[ -r "$adresár" ]]; then
				súbory+=("$adresár")
			fi
		fi
	fi
}
hĺbka=""
cesta=""
while (("$#")); do
	case "$1" in
	-h)
		pomoc
		exit 0
		;;
	-d)
		shift
		je_číslo="^[0-9]+$"
		if [[ "$1" =~ $je_číslo ]]; then
			hĺbka=$1
		else
			zlá_hod=$1
			printf "Chyba: \'Neplatná hodnota pre hĺbku -> %s\'\n" "$zlá_hod" 1>&2
			exit 1
		fi
		;;
	-*)
		printf "Chyba: \'Neplatný prepínač -> %s\'\n" "$1" 1>&2
		exit 1
		;;
	*)
		if test -d "$1"; then
			cesta="$1"
		else
			zlá_cesta="$1"
			printf "Chyba: \'Neplatná cesta / Cesta do adresára neexistuje -> %s\'\n" "$zlá_cesta" 1>&2
			exit 1
		fi
		;;
	esac
	shift
done
if [[ -z "$cesta" ]]; then
	cesta="."
fi
if [ -z "$hĺbka" ]; then
	adresáre=$(find "$cesta" -type f 2>&1)
	while read -r adresár; do
		pridaj_súbory "$adresár"
	done <<<"$adresáre"
else
	adresáre=$(find "$cesta" -maxdepth "$hĺbka" -type f 2>&1)
	while read -r adresár; do
		pridaj_súbory "$adresár"
	done <<<"$adresáre"
fi
for súbor in "${súbory[@]}"; do
	názov=$(basename "$súbor")
	počet=$(grep -wc "$názov" "$súbor")
	if [[ $počet -gt 0 ]]; then
		printf "Výstup: \'%s %s\'\n" "$súbor" "$počet"
	fi
done
exit 0
