# !/bin/sh

if [ "$1" = "" ]
then
    exit 0
fi

ptype='transfer_d'
path='/somefolder/transfer'

nomer[1]=$1
nomer[2]=$2
nomer[3]=$3
nomer[4]=$4
nomer[5]=$5
nomer[6]=$6

#Проверим, запущено ли.
if [ -s "/$path/d/"$ptype"_"$7"_$(uname -n)_$(echo $USER).pid" ]
then
    var0=0
else
    touch "/$path/d/"$ptype"_"$7"_$(uname -n)_$(echo $USER).pid"
    echo "9999999999" > "/$path/d/"$ptype"_"$7"_$(uname -n)_$(echo $USER).pid"
fi

if [ $(pidof sh | grep $(cat "/$path/d/"$ptype"_"$7"_$(uname -n)_$(echo $USER).pid") | wc -l) == "1" ]
then
    date +%d/%m/%y-%T >> log/err_$7.log;
    echo "Уже запущено. Fail!" >> log/err_$7.log;
    exit
else
    date +%d/%m/%y-%T >> log/err_$7.log;
    echo "Всё нормально. All right. Run." >> log/err_$7.log;
    echo $$ > "/$path/d/"$ptype"_"$7"_$(uname -n)_$(echo $USER).pid"
fi
#----------------------

z=''
zxid=''
live=1
sql=''
var0=0
i=81
fname=''
stopfile='stop/transfer_'"$7"

while [ ! -f "$stopfile" ]
do
    for B in '1' '2' '3' '4' '6'
    do
	for A in '1' '2' '3' '4' '5' '6'
	do
	    if [ "${nomer[$A]}" -ne "00" ]
	    then
		let var1=10#${nomer[$A]}-0
		ping 192.168.$var1.252 -c 2 > /dev/null
		
		if [ $? -ne 0 ]
		then 
		    echo "sadly, no ping КЯ${nomer[$A]} at $(date +%d/%m/%y-%T)..." >> log/transfer_$7.log
		    continue
		fi
		#---------------------------------------------------------------------------------------------------------------------
		
		if [ -s "transfer_$B.sh" ]   #
		then
		    sh "transfer_$B.sh" ${nomer[$A]} $7 >> log/transfer_$7.log
		else
		    cp "/home/username/scripts/transfer/transfer_$B.sh" "$(pwd)"
		    sh "transfer_$B.sh" ${nomer[$A]} $7 >> log/transfer_$7.log
		fi
		
		#---------------------------------------------------------------------------------------------------------------------
	    fi
	    
	done
	
    done
    echo $i
    sleep 95
done
rm -f "$stopfile"
exit 0