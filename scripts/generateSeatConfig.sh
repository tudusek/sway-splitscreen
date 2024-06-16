#/bin/bash

seats=$(swaymsg -t get_seats | \
  jq -r '[.[] | select(.name !="seat0" )]')

seatNames=$(echo $seats | jq -r '.[].name')

for seatName in $seatNames
do
  devices=$(echo $seats | \
    jq -r '.[] | select(.name == "'$seatName'").devices.[].identifier' | \
    sort | uniq )
  for device in $devices
  do
    echo swaymsg seat $seatName attach $device 
  done 
done

