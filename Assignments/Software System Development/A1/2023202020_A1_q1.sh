#!/bin/bash
echo -n "Jaggu X =  "
read jx
echo -n "Jaggu Y = "
read jy
echo -n "Police X = "
read px
echo -n "Police Y = "
read py
echo -n "H = "
read h

dif1=$(echo "$px-$jx" | bc)
dif2=$(echo "$py-$jy" | bc)

sq1=$(echo "$dif1*$dif1" | bc)
sq2=$(echo "$dif2*$dif2" | bc)

fin=$(echo "$sq1+$sq2" | bc)

#sq_r=0
sq=$(echo "scale=2; sqrt($fin)" | bc )

if [[ $(echo "if (${sq} < 2) 1 else 0" | bc) -eq 1 ]]
then  
    echo "Distance Reached"
    exit 1
fi

for(( i=1; i<=h; i++ ))
do
    echo -n "Police X = "
    read pxc
    echo -n "Police Y = "
    read pyc

    if (( $(echo "$pxc>$jx && $pyc>$jy" | bc) == 1 ))
    then 
        direction=SW
    elif (( $(echo "$pxc<$jx && $pyc>$jy" | bc) == 1))
    then
        direction=SE
    elif (( $(echo "$pxc<$jx && $pyc<$jy" | bc) == 1))
    then
        direction=NE
    elif (( $(echo "$pxc>$jx && $pyc<$jy" | bc) == 1))
    then
        direction=NW
    elif (( $(echo "$pxc>$jx && $pyc=$jy" | bc) == 1))
    then
        direction=S
    elif (( $(echo "$pxc=$jx && $pyc<$jy" | bc) == 1))
    then
        direction=N
    elif (( $(echo "$pxc<$jx && $pyc=$jy" | bc) == 1))
    then
        direction=W
    else 
        direction=E
    fi

    dif1=$(echo "$pxc-$jx" | bc)
    dif2=$(echo "$pyc-$jy" | bc)

    sq1=$(echo "$dif1*$dif1" | bc)
    sq2=$(echo "$dif2*$dif2" | bc)

    fin=$(echo "$sq1+$sq2" | bc)

   #echo "scale=2; sqrt($fin)" | bc
   sq=$(echo "scale=4; sqrt($fin)" | bc )
   #sq=$(bc -l <<< "sqrt($fin)")
    sq_r=$(printf "%.2f" $sq)
   #echo $sq_r

   

   if [ $(echo "$sq_r > 2" | bc) -eq 1 ];
   then     
        echo "$sq_r $direction"
    else 
        echo "Distance reached"
    fi
done 

if [ $(echo "$sq_r > 2" | bc) -eq 1  ]
then    
    echo "Time over"
fi

