#!/bin/bash

TOWN="Oras: "
COUNTRY="Tara: "
TEMPERATURE="Temperatura: "

usage(){
	echo "weather [oras] -option"
	exit 1
}

#check the number of parameters
if [ $# -ne 2 ]; then
	usage
fi

TOWN_PARAM=$(echo $1 | tr -d '"')
TOWN_FPATH=ex1/all/$TOWN_PARAM.txt

if [[ $2 == "-r" ]] ; then
  	mkdir -p ex1/all

	QUERY_RES=$(curl -s wttr.in/"$TOWN_PARAM" |tail -3 |head -1)

	LATITUDE=$(echo $QUERY_RES | grep -Po '(?<=\[).*?(?=,)')
	LONGITUDE=$(echo $QUERY_RES | grep -Po '(?<=,)[0-9-.]*?(?=\])')

	QUERY_COUNTRY=$(curl -s -X GET -H 'Content-Type: *' \
	--get 'https://weather.cit.api.here.com/weather/1.0/report.json' \
	--data-urlencode 'product=observation' \
	--data-urlencode "latitude=$LATITUDE"  --data-urlencode "longitude=$LONGITUDE" \
	--data-urlencode 'oneobservation=true' --data-urlencode 'app_id=DemoAppId01082013GAL' \
	--data-urlencode 'app_code=AJKnXv84fjrb0KIHawS0Tg' \
	| grep -Po 'country":".*?"' | head -1 | sed s/country// | tr -d '":')

	QUERY_TEMP=$(curl -s wttr.in/"$TOWN_PARAM"?format=%t)
	TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")

	TIME_FPATH="ex1/RUN[$TIMESTAMP].txt"
	touch $TIME_FPATH
	printf "$TOWN$TOWN_PARAM\n$COUNTRY$QUERY_COUNTRY\n$TEMPERATURE$QUERY_TEMP" > $TIME_FPATH

	touch "$TOWN_FPATH"
	printf "[$TIMESTAMP] - $QUERY_TEMP\n" >> "$TOWN_FPATH"

elif [[ $2 == "-x" ]]; then
	rm "ex1/all/$TOWN_PARAM.txt" 2</dev/null

	for file in ex1/*; do
    if [ -f "$file" ]; then
				TOWN_NAME=$(head -1 $file | grep -Po '(?<=\:\ ).*')
				if [ "$TOWN_NAME" == "$TOWN_PARAM" ]; then
					rm "$file"
				fi
    fi
	done

elif [[ $2 == "-l" ]]; then
	LINES_CNT=$(wc -l 2>/dev/null < "$TOWN_FPATH")
	if [ $? -eq 0 ]; then
		echo $LINES_CNT
	fi
else
	usage
fi
