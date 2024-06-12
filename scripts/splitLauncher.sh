#!/bin/bash

#where to store players home directories
homeDir=~/bwrap

layout=$(zenity --forms \
  --title='splitLauncher' \
  --text="Enter layout" \
  --add-entry=rows \
  --add-entry=columns \
  --add-combo="action" \
  --combo-values='flatpak|bwrap' \
  --separator=' ')

rows=$(echo $layout | awk '{print $1}')
columns=$(echo $layout | awk '{print $2}')
action=$(echo $layout | awk '{print $3}')

re='^[0-9]+$'
if ! [[ $rows =~ $re ]] ; then
   echo "error: Not a number" 
   exit 0
fi
if ! [[ $columns =~ $re ]] ; then
   echo "error: Not a number" 
   exit 0
fi

echo "$action"
if [ "$action" == "flatpak" ]; then
  app=$(zenity --list \
    --title="splitLauncher" \
    --text="Select app to run" \
    --column=app \
    --separator=' ' \
    $(flatpak list --app | awk -F '\t'  '{print $2}'))
elif [ "$action" == "bwrap" ]; then
  app=$(zenity --entry \
    --title="splitLauncher" \
    --text="enter command to run")
fi

if [ "$app" == "" ];then
  exit 0
fi

#Kill all subprocesses if SIGINT recieved
pids=()
function cleanup () {
  for pid in $pids
  do
    kill $pid
  done 
}

trap cleanup SIGINT

#Setup xwaylands
x=1
for ((i=1;i<=columns;i++)); do
  for ((j=1;j<=rows;j++));do
    Xwayland -noreset :$x &
    pids="$pids $!"
    ((x++))
    sleep 0.5s
    if ((j == 1 && i != 1));then
      swaymsg move right
    fi
    sleep 0.2s
    if((j == 1));then
      swaymsg splitv
    fi
  done
done

#launch window manager
count=$(($rows*$columns))
for ((i=1;i<=count;i++)); do
  xfwm4 --display=:$i &
  pids="$pids $!"
done

#set colored background
colors=( "red" "blue" "green" "yellow" "orange" "purple" "pink" "white" )
if command -v hsetroot &> /dev/null
then
  for ((i=1;i<=count;i++)); do
    env DISPLAY=:$i hsetroot -solid "${colors[((i-1))]}"
  done
fi

#launch apps
for (( i=1; i<=count; i++ ));do
  mkdir -p $homeDir/p$i
  if [ "$action" == "flatpak" ]; then
    env WAYLAND_DISPLAY="" XDG_SESSION_TYPE=x11 DISPLAY=:$i HOME=$homeDir/p$i flatpak run $app &
  elif [ "$action" == "bwrap" ]; then
    env WAYLAND_DISPLAY="" XDG_SESSION_TYPE=x11 DISPLAY=:$i bwrap --dev-bind / / --dev-bind $homeDir/p$i $HOME $app &
  fi
  pids="$pids $!"
done
wait
