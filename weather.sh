#!/bin/bash

TOWN="Oras: "
COUNTRY="Tara: "
TEMPERATURE="Temperatura: "

usage(){
	echo "weather [oras] -option"
	exit 1
}

#check the number of parameters
if [ $# -ne 2 ]
then
	usage
fi

if [[ $2 == "-r" ]]
then
  	mkdir -p ex1/all

	TOWN_PARAM=$(echo $1 | tr -d '"')
	QUERY_RES=$(curl -s wttr.in/"$TOWN_PARAM" |tail -3 |head -1)

	#(?=,|\[) added "\[" for the "Location: Berlin [52.52045,13.40732]" example
	AUX_QUERY_TOWN=$(echo $QUERY_RES | grep -Po '(?<=:).*?(?=,|\[)')
	QUERY_TOWN=$(echo $AUX_QUERY_TOWN |  (sed 's/^ //; s/ $//') )

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
	printf "$TOWN$QUERY_TOWN\n$COUNTRY$QUERY_COUNTRY\n$TEMPERATURE$QUERY_TEMP" > $TIME_FPATH

	TOWN_FPATH="ex1/all/$QUERY_TOWN.txt"
	touch $TOWN_FPATH
	printf "[$TIMESTAMP] - $QUERY_TEMP\n" >> $TOWN_FPATH

elif [[ $2 == "-x" ]]
then
	echo "$2 remove"
elif [[ $2 == "-l" ]]
then
	echo "$2 list"
else
	usage
fi
