#!/bin/bash

ptype='transfer_d'
path='/somefolder/'
pathtemp='/somefolder/temp/'

if [ -d "/somefolder/tmp" ]
then
    var0=0
else
    mkdir "/somefolder/tmp"
fi


#files in office, где всё в офисе.
files_in='folder0'

#out где всё на точке.
files_out='folder1'

user="user";
pass="123456";

nomer=$1
let var1=10#$nomer-0
echo "1 start for $1 at" "$(date +%d/%m/%y-%T)"

#---------------------------------------------------------------------------------------------------------------------

if [ -d "$pathtemp$files_in$nomer/" ]
then
    var0=0
else
    mkdir "$pathtemp$files_in$nomer/"
fi

cd "$path$files_in$nomer/"

if [ "$?" -ne 0 ]
then
    sleep 5
    exit 0
fi

for C in $(find * -maxdepth 0 -type d 2> /dev/null)
do
    if [ -d "$pathtemp$files_in$nomer/$C/" ]
    then
	var0=0
    else
	mkdir "$pathtemp$files_in$nomer/$C/"
    fi
    
    cd "$path$files_in$nomer/$C/"
    
    if [ "$?" -ne 0 ]
    then
	sleep 5
	continue
    fi
    
    for fname in $(find * -maxdepth 0 -type f 2> /dev/null | egrep -v -i 'transfer|readme|start|stop')
    do
	if [ -f "$fname" ]
	then
	    cp "$fname" "$pathtemp$files_in$nomer/$C/" 2> /dev/null
	    if [ "$(stat -c %s "$fname")" == "$(stat -c %s "$pathtemp$files_in$nomer/$C/$fname")" ]
	    then 
		rm -f "$fname" 2> /dev/null
	    fi
	fi
    done

    cd "$pathtemp$files_in$nomer/$C"

    if [ "$?" -ne 0 ]
    then
	sleep 5
	continue
    fi
    
    for fname in $(find * -maxdepth 0 -type f 2> /dev/null)
    do
	if [ -f "$fname" ] 
	then
 	    smbclient //192.168.$var1.1/share -U $user $pass -c "cd $files_out\\$C; recurse; prompt; mput $fname; exit" > /dev/null
	    if [ "$(smbclient //192.168.$var1.1/share -U $user $pass -c "cd $files_out\\$C; ls; exit" | grep "$fname")" != "" ]
	    then
		rm -f "$fname" 2> /dev/null
	    fi
	fi
    done
done

cd "/somefolder/tmp"

#---------------------------------------------------------------------------------------------------------------------

echo "1 complete for $1 at" "$(date +%d/%m/%y-%T)"

exit 0