#!/bin/bash

echo "Enter number of days: "
read days
echo "Enter the price of stock on $days days: "
read -a print
#print=()
: 'for(( i=1; i<=days; i++ ))
do
    read ele
    print+=("$ele")
    
done '

: 'for i in "${print[@]}"
do  
    echo "$i"
done'


max=0
#echo $max
for ((i=1;i<=days;i++))
do
    for((j=i+1;j<=days;j++))
    do
        dif=$((print[$j] - print[$i]))
        if [ $dif -gt 0 ]
        then
            if [ $dif -gt $max ]
            then    
                max=$dif
            fi
        fi
    done
done

echo "Maximun profit $max"



