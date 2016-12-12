#! /bin/sh

path="/somfolder/transfer";

#Проверим, запущено ли.
if [ -s "/$path/d/transfer_watcher_$(uname -n)_$(echo $USER).pid" ]
then
    var0=0
else
    touch "/$path/d/transfer_watcher_$(uname -n)_$(echo $USER).pid"
    echo "9999999999" > "/$path/d/transfer_watcher_$(uname -n)_$(echo $USER).pid"
fi
if [ $(pidof sh | grep $(cat "/$path/d/transfer_watcher_$(uname -n)_$(echo $USER).pid") | wc -l) == "1" ]
then
    date +%d/%m/%y-%T >> log/while.log;
    echo "Уже запущено. Fail!" >> log/while.log;
    exit
else
    date +%d/%m/%y-%T >> log/while.log;
    echo "Всё нормально. All right. Run." >> log/while.log;
    echo $$ > "/$path/d/transfer_watcher_$(uname -n)_$(echo $USER).pid"
fi
#----------------------

var0=0

while [ $var0 -eq "0" ]
do	
    echo "$(date +%d/%m/%y-%T)" >> "/$path/log/transfer_watcher.log"
    for A in "$(ps -eo pid,etime,command | grep "\<[s]h transfer_" | awk '{ print $1, $2}')"
    #while [ $(read A) ]
    do
	if [ "$A" = "" ]
	then 
	    break
	fi
	#echo "$A"
	B=($A)
	C=${B[1]}
	let D="${C%%:*}"-0
	
	if [ "$D" -gt "9" ] || [ "${#C}" -gt "5" ]
	then 
	    echo "PID ${A[1]} have bad etime: "$D" min" >> "/$path/log/transfer_watcher.log"
	    kill ${B[0]}
	fi
    done
    #---------------
    cd "/$path/d" 2> /dev/null

    for A in $(find * -maxdepth 0 -type f 2> /dev/null | grep -i "W_d_" | grep "$(uname -n)" | grep "$(echo $USER)")
    do
	#echo "$A"
	if [ "$(ps -eo pid,etime,command | grep '[t]ransfer' | grep -i -v "watcher" | grep -w "$(cat "$A")")" = "" ]
	then
	    echo "Bad((( $A not runing..." >> "/$path/log/transfer_watcher.log"
	    echo "A $A"
	    #rm -f "$A"
	    B=$(echo $A | sed 's/.pid//' | sed 's/transfer_d_//' |  head -c 2 | sed 's/_//')
	    echo "B $B"
	    C="$(cat "/$path/start_transfer" | grep "transfer_$B.log" | sed 's/sh //')"
	    echo "C $C"
	    cd "/$path"
	    echo "sh $A $B $C"  >> "/$path/log/transfer_watcher.log"
	    D="$(echo "$C" | sed 's/&>> //' | sed s/transfer_$B.log// | sed 's/&//' | sed 's/["][1-9a-zA-Z/]* //' | sed 's/^[^"]*//' | sed 's/["] //' | sed 's/ log[/]//')"
	    echo $D
	    sh "/$path/transfer.sh" $D &>> log/transfer_$B.log &
	    cd "/$path/d" 2> /dev/null
	    sleep 90
	else
	    var0=0
	fi

    done
    cd "/$path"
    #---------------
    sleep 301
done

exit 0
