pattern='^[0-9]+$'
LOGFILE=/public/logs/access.2020
if [[ ! -r "$LOGFILE" ]]; then
	echo "Chyba: 'Nemožno čítať $LOGFILE': Súbor neexistuje alebo chýbajú oprávnenia" 1>&2
	exit 1
fi
if [[ $1 == "-h" && -z $2 ]]; then
	cat <<EOF
	$0 (C)
	Použitie: $0 [-h] [-n <počet>]
	-h: Zobraziť nápovedu
	-n <počet>: Zobraziť používateľov, ktorí sa prihlásili viackrát ako <počet> krát v určenom období
EOF
	exit 0
elif [[ ($1 == "-n" && $2 =~ $pattern && -z $3) || -z $1 ]]; then
	last -f $LOGFILE | head -n -2 | sed 's/Jan/01/g;s/Feb/02/g;s/Mar/03/g;s/Apr/04/g;s/May/05/g;s/Jun/06/g;s/Jul/07/g;s/Aug/08/g;s/Sep/09/g;s/Oct/10/g;s/Nov/11/g;s/Dec/12/g' | sort -n -k5 -k6 | awk -v limit="$2" '
	
		{
			posun = ($7 == "-" ? 0 : 1 )
		
			datumCas = $(4+posun)"-"$(5+posun)" "$(6+posun)
		}
		$(6+posun) >= "22" || $(6+posun) < "05" {
			zaznamy[$1] = datumCas
			pocitadlo[$1]++
		}
		END{
			for(pouzivatel in zaznamy)
				if(limit == "" || limit < pocitadlo[pouzivatel])
					printf "Výstup: \047"pouzivatel" "pocitadlo[pouzivatel]" "zaznamy[pouzivatel]"\047\n"
		}		
	'
else
	echo "Chyba: Nesprávny argument" 1>&2
	exit 1
fi
exit 0
