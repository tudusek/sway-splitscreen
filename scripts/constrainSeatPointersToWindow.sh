#!/bin/bash
seats=$(swaymsg -t get_seats)
seat=$(zenity --list \
  --title="configSeat" \
  --text="Select devices for seat$seatnum. Multiple devices can be selected by holding ctrl key" \
  --column=device \
  --separator=' ' \
  $(echo $seats | \
    jq -r '.[].name '))

if [ "$seat" == "" ];then
  exit
fi

sleep 0.3s

rect=$(swaymsg -t get_tree \
  | jq -r '[recurse(.nodes[]) | del(.nodes[]) | select(.pid != null) | .rect] | unique | .[] | "\(.x),\(.y) \(.width)x\(.height)"' \
  | slurp -o -r -f '%x %y %w %h' 2> /dev/null )

if [ "$rect" == "" ];then
  exit
fi

x=$(echo $rect | awk '{print $1}')
y=$(echo $rect | awk '{print $2}')
w=$(echo $rect | awk '{print $3}')
h=$(echo $rect | awk '{print $4}')

devices=$(echo $seats\
  | jq -r '.[] | select(.name == "'$seat'").devices[] | select(.type == "pointer" or .type == "touchpad").identifier')

for device in $devices; do
  swaymsg input $device map_to_region $x $y $w $h
done
