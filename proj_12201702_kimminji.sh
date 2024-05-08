#! /bin/bash

if [ $# -ne 3 ]
then
	echo "usage: $0 file1 file2 file3"
	exit 1 #fail
fi

echo "**********OSS - Project1**********"
echo "*      StudentID : 12201702      *"
echo "*        Name : Kim Minji        *"
echo "**********************************"

teams=$1
players=$2
matches=$3

while true; do
    echo -e  "\n\n[MENU]" #print menu & get choice from user
    echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
    echo "2. Get the team data to enter a league position in teams.csv"
    echo "3. Get the Top-3 Attendance matches in mateches.csv"
    echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
    echo "5. Get the modified format of date_GMT in matches.csv"
    echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
    echo "7. Exit"

    read -p "Enter your CHOICE: " choice

    case $choice in
        1)
		read -p "Do you want to get the Heung_Min Son's data? (y/n) : " yn
		if [ "$yn" = "y" ]
		then
			cat "$players" | awk -F',' '$1~"Heung-Min Son"{print "Team:"$4", Appearance:"$6", Goal:"$7", Assist:"$8}'
			# Using awk to find "Heung-Min Son" and print his data
		else
			echo "Undo your choice."
		fi
		;;
        2)
		read -p "What do you want to get the team data of league_position[1-20]: " position
		cat "$teams" | awk -F',' -v pos="$position" '$6 == pos{rate = $2/($2+$3+$4); print $6" "$1" "rate}'
		# Find position & calculate winning rate using variables
		;;
        3)
		read -p "Do you want to know Top-3 attendance data and average attendance? (y/n) : " yn
		if [ "$yn" = "y" ]
		then
			echo -e "***Top-3 Attendance Match***\n"
			cat "$matches" | sort -r -t',' -n -k 2 | head -n 3 | awk -F',' '{print $3" vs "$4" ("$1")\n"$2" "$7"\n"}'
		else
                        echo "Undo your choice."
		fi
		# When sorting, use the option '-t' to set the separator and '-n' to recognize fields as number
		# Cutting line and using awk for print
		;;
        4)
		read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " yn
		if [ "$yn" = "y" ]
		then
			echo ""
			cat "$teams" | sort -t',' -n -k 6 | cut -d',' -f1 > teamName.txt
			# Sort 'teams.csv' by league_position and save team names to 'teamName.txt' 
			count=1
			IFS=$'\n'
			# Set the separator
			for name in $(cat teamName.txt)
			do
				if [ "$name" == "common_name" ]
				then
					continue
					# Pass field Name
				fi
				echo "$count $name" # Print team name
				((count += 1))
				cat "$players" | awk -F',' -v team="$name" '$4 == team{print $1","$7}' | sort -r -t',' -n -k 2 | head -n 1 | tr ',' ' '
				# Sort players by goal_overall and print the top player
				echo ""
			done

		else
                        echo "Undo your choice."
		fi
		;;
        5)
		read -p "Do you want too modity the format of date? (y/n) : " yn
		if [ "$yn" = "y" ]
		then
			cat "$matches" | cut -d',' -f1 | head -n 11 | tail -n +2 | sed -E -e 's/([A-Za-z]{3}) ([0-9]{2}) ([0-9]{4}) - /\3\/\1\/\2 /' | sed -E -e 's/Jan/01/; s/Feb/02/; s/Mar/03/; s/Apr/04/; s/May/05/; s/Jun/06/; s/Jul/07/; s/Aug/08/'
		else
                        echo "Undo your choice."
		fi
		# Cut the 'matches.csv' to print only 10 lines without fields name
		# Then use the 'sed' command to format the line to 'yyyy/mmm/dd' and replacing 'mmm' to 'mm'
		;;
        6)
		cat "$teams" | tail -n 20 | awk -F',' '{print NR") "$1}' # Print team name
		read -p "Enter your team number: " teamNum # Read number
		teamName=$(cat "$teams" | tail -n 20 | awk -F',' -v num=$teamNum 'NR==num{print $1}')
		# Save teamName to use 'matches.csv'
		cat "$matches" | awk -F',' -v team="$teamName" '$3 == team && $5>$6{print $1","$5","$6}' > log.txt
		# Save match datas to 'log.txt'
		IFS=$'\n'
		max_score=0
		for match in $(cat log.txt)
		do
			IFS=',' read -r f1 f2 f3 <<< "$match"
			score_diff=$((f2 - f3))
			if ((score_diff > max_score))
			then
				max_score=$score_diff
			fi
		done
		# Use 'log.txt' to find the max value of score difference
		cat "$matches" | awk -F',' -v team="$teamName" -v max_diff=$max_score '$3 == team && ($5 - $6) == max_diff{print "\n"$1"\n"$3" "$5" vs "$6" "$4}'
		# Print the match datas that the score differenxe is equal to max value
		;;
        7)
            break
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac
done

echo "Bye!"
