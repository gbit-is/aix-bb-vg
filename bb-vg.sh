#!/bin/sh

vgs=$(lsvg -o) # List all VG's
#vgs=$(lsvg -o | grep -E "name|of|vgs|to|monitor" | grep -Ev "names|of|vgs|to|ignore ) # List and filter out VG's

#                                                                        / Yes ------ Red flag
#                           / Yes  ---- Is total free less then minsize ?
# ----Red threshold reached ?                   /yes, yelllow flag       \  No ------  Yellow flag
#                           \ No  - Yel thre reached ?                          / Yes, green flag
#                                                   \ no --- Green flag there ?
#                                                                              \ No, Error state reached. Red flag

redthresh=99 #Set Threshold for red
yelthresh=85  #Set Threshold for yellow
minsizegb=500 #GB 
minsize=$(( minsizegb * 1000 ))  #MB



tmp=/full/path/to/xymon/tmp/vgout$$.txt #set temp file
bb="/full/path/to/xymon/client nameofxymonserver" #Set hobbit client location

echo " " > $tmp #Empty out temp and create empty line (Just a failsafe measure)



for vg in $vgs;do   #The main test. Check all VG's
	col=green   #Initialise line-color test as green

	tot=$(lsvg $vg | grep "TOTAL PPs" | awk '{print $6}') # Get total VG's
	fre=$(lsvg $vg | grep "USED PPs" | awk '{print $5}')  # Get Free VG's
	per=$(( 100*$fre/$tot ))                              # Calculate percentage


	if [[ $per -gt $redthresh && $fre -lt $minsize ]];then                       # If it reaches the threshold and is less then the threshold
		red="TRUE"                                    # Set the main red flag
		col="red"                                     # set the line color




	elif [ $per -gt $yelthresh ]; then                    # If it reaches the yellow threshold
		yel="TRUE"                                    # Set the yellow flag
		col="yellow"                                  # Set the line color
	else
		gre="TRUE"                                    # If no threshold. Set green
		col="green"                                   # Set line color green. Redundant
		
	fi

	echo "&$col $vg $per% full" >> $tmp               # Print summary of each VG to head of file
done



echo "" >> $tmp  #Create some linespace
echo "" >> $tmp  #Create some linespace



for i in $vgs;do lsvg $i >> $tmp;echo >> $tmp;echo >> $tmp;done  # Print out a full list of VG summarys. Extra echos added for readability

if [[ "$red" == "TRUE" ]];then                              # If red is worst color

	echo "red"
	$bb "status+7h $(hostname).vg red $(echo $(hostname)   $(date))  $(cat $tmp)"
	

elif [[ "$yel" == "TRUE" ]];then                            # If Yellow is worst color

	echo "yellow"	
	$bb "status+7h $(hostname).vg yellow $(echo $(hostname)   $(date))  $(cat $tmp)"


elif [[ "$gre" == "TRUE" ]];then                           # If green is "worst" color
	
	echo "green"
	$bb "status+7h $(hostname).vg green $(echo $(hostname)   $(date))  $(cat $tmp)"


else
	$bb "status+7h $(hostname).vg red $(echo $(hostname)   $(date))  'What the bleep ? No color was found ? something went wrong here' "



fi
