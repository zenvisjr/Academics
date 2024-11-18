#! /bin/bash


set -f
input=$1
count=$(wc -l < $1)
#echo $count

while read -r line
do 
    arr=($line)
    #final=()
    i=0
    j=$((${#arr[@]}-1))
    #echo $j
    #echo "${arr[i]}"
    #echo "${arr[j]}"
    while(( i<j ))
    do
        if [ "${arr[i]}" == '#' ] || [ "${arr[i]}" == '$' ] || [ "${arr[i]}" == '*' ] || [ "${arr[i]}" == '@' ] && \
        [ "${arr[j]}" == '#' ] || [ "${arr[j]}" == '$' ] || [ "${arr[j]}" == '*' ] || [ "${arr[j]}" == '@' ]
        #if (( "${arr[i]}" == "#" ||  "${arr[i]}" == "$"  || "${arr[i]}" == "*" || "${arr[i]}" == "@" ))
        then
            i=$((i+1))
            j=$((j-1))
            continue;

        elif [ "${arr[i]}" == '#' ] || [ "${arr[i]}" == '$' ] || [ "${arr[i]}" == '*' ] || [ "${arr[i]}" == '@' ]
        #if (( "${arr[i]}" == "#" ||  "${arr[i]}" == "$"  || "${arr[i]}" == "*" || "${arr[i]}" == "@" ))
        then
            i=$((i+1))
            continue;

        elif [ "${arr[j]}" == '#' ] || [ "${arr[j]}" == '$' ] || [ "${arr[j]}" == '*' ] || [ "${arr[j]}" == '@' ]
        #if (( "${arr[i]}" == "#" ||  "${arr[i]}" == "$"  || "${arr[i]}" == "*" || "${arr[i]}" == "@" ))
        then
            j=$((j-1))
            continue;
        
        else
            temp="${arr[j]}"
            arr[j]="${arr[i]}"
            arr[i]="$temp"
            
            i=$((i+1))
            j=$((j-1))
    
        fi
        
        #echo "${arr[i]}"
    done

    for i in "${arr[@]}"
    do  
        echo -n "$i "
    done

    echo 
done <$input

set +f

