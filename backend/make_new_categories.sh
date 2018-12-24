#!/bin/bash

cd /var/tmp/steamy_cats/ || exit

echo "Adding new category tags to the games!"

function makecats
{
	let VALNUM=100
	CATS=$(jq '.[] | .data.categories' "$HOME/.local/share/steam_store_api_json/$1.html" 2> /dev/null | grep description | cut -d\" -f4)
	echo "$CATS" | while read -r line
	do
		if [ "$line" == "" ]
		then
			printf "\t\t\t\t\t\t\t\"%s\"\t\t\"%s\"\n" "$VALNUM" "FLAGS NONE" >> /var/tmp/steamy_cats/"$1"
		else
			printf "\t\t\t\t\t\t\t\"%s\"\t\t\"FLAGS %s\"\n" "$VALNUM" "$line" >> /var/tmp/steamy_cats/"$1"
		fi
		let VALNUM=$VALNUM+1
	done

	if [ -f "$HOME/.local/share/steam_store_frontend/$1.html" ]
	then
		if grep -q "You must login to see this content." "$HOME/.local/share/steam_store_frontend/$1.html"
		then
			printf "\t\t\t\t\t\t\t\"%s\"\t\t\"%s\"\n" "304" "FLAGS ADULT" >> /var/tmp/steamy_cats/"$1"
		fi

		# This is basically the same as the flags above, but making it a function complicates things a bit IMO
		let VALNUM=200
		TAGS=$(grep -A1 InitAppTagModal "$HOME/.local/share/steam_store_frontend/$1.html" | tail -1 | jq '.[] | .name' 2> /dev/null | cut -d\" -f2)
		echo "$TAGS" | while read -r line
		do
			if [ "$line" == "" ]
			then
				printf "\t\t\t\t\t\t\t\"%s\"\t\t\"%s\"\n" "$VALNUM" "TAGS NONE" >> /var/tmp/steamy_cats/"$1"
			else
				printf "\t\t\t\t\t\t\t\"%s\"\t\t\"TAGS %s\"\n" "$VALNUM" "$line" >> /var/tmp/steamy_cats/"$1"
			fi
			let VALNUM=$VALNUM+1
		done
	else
		printf "\t\t\t\t\t\t\t\"%s\"\t\t\"%s\"\n" "200" "TAGS NONE" >> /var/tmp/steamy_cats/"$1"
	fi

	if grep -q '"linux":true' "$HOME/.local/share/steam_store_api_json/$1.html"
	then
		printf "\t\t\t\t\t\t\t\"%s\"\t\t\"APP NATIVE LINUX\"\n" "300" >> /var/tmp/steamy_cats/"$1"
	#else
		#DIR=$(dirname "$0")
		#"$DIR"/proton_db_ratings.sh
	fi

	{
		printf "\t\t\t\t\t\t\t\"%s\"\t\t\"ALL\"\n" "301"
		printf "\t\t\t\t\t\t}\n"
	} >> /var/tmp/steamy_cats/"$1"

	if grep -q $'\t\t\t\t\t"Hidden"\t\t"' /var/tmp/steamy_cats/"$1"
	then
		HIDDENLINE=$(grep $'\t\t\t\t\t"Hidden"' /var/tmp/steamy_cats/"$1")
		grep -hv $'\t\t\t\t\t"Hidden"' /var/tmp/steamy_cats/"$1" > /var/tmp/Steamy_Cats_Rewrite.$1
		cp /var/tmp/Steamy_Cats_Rewrite.$1 /var/tmp/steamy_cats/"$1"
		echo "$HIDDENLINE" >> /var/tmp/steamy_cats/"$1"
	fi

	printf "\t\t\t\t\t}\n" >> /var/tmp/steamy_cats/"$1"

}

for i in *
do
	makecats "$i" &
done
wait
