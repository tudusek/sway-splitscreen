#!/bin/bash
homeDir=~/bwrap
overlayFolder=""
zenityArgs='--title=newPlayer.sh'

pids=()
function cleanup () {
  for pid in $pids
  do
    kill $pid
  done 
  if [ "$overlayFolder" != "" ]; then
    fusermount -u "$homeDir"/"$user"/Overlay
  fi
  if [ "$user" != "" ]; then
    rm /tmp/splitScreen/$user.lock
  fi
}
trap cleanup SIGINT
trap cleanup SIGTERM

if [ ! -d "/tmp/splitScreen" ];then
  mkdir /tmp/splitScreen
fi

if [ ! -d "$homeDir" ];then
  mkdir -p $homeDir
fi

x=$(ls -1 /tmp/.X11-unix | sed 's/X//g' | sort -g | tail -n 1)
((x++))

Xwayland -noreset :$x &
pids="$pids $!"
xfwm4 --display=:$x &
pids="$pids $!"

sleep 0.5s
while true
do
  users="NEW_USER "$(ls -1d $homeDir/* | sed "s/$(echo $homeDir | sed 's/\//\\\//g' )\///g") 
  user=$(env WAYLAND_DISPLAY='' DISPLAY=:$x zenity $zenityArgs --list \
    --text="Select user" \
    --column=app \
    --separator=' ' \
    $users)
  if [ "$user" == "" ];then
    cleanup
    exit
  elif [ "$user" == "NEW_USER" ]; then
    while true;do
      newUser=$(env WAYLAND_DISPLAY='' DISPLAY=:$x zenity $zenityArgs --entry --text='type your username')
      if [ "$newUser" == "" ];then
        cleanup
        exit 
      elif [[ $newUser =~ ^[0-9a-zA-Z]+$ ]]; then
        if [ -d "$homeDir/$newUser" ];then
          env WAYLAND_DISPLAY='' DISPLAY=:$x zenity $zenityArgs --info --text='user already exist'
        else
          if [ -f "/tmp/splitScreen/$newUser.lock" ]; then
            rm /tmp/splitScreen/$newUser.lock
          fi
          mkdir -p $homeDir/$newUser
          user=$newUser
          break
        fi
      fi
    done
  fi

  if [ -f "/tmp/splitScreen/$user.lock" ]; then
    env WAYLAND_DISPLAY='' DISPLAY=:$x zenity $zenityArgs --info --text='player is already taken'
  else
    break
  fi
done

touch /tmp/splitScreen/"$user".lock

form=$(env WAYLAND_DISPLAY='' DISPLAY=:$x zenity $zenityArgs --forms \
  --add-combo="type" \
  --combo-values='flatpak|bwrap' \
  --separator=' ')

type=$(echo $form | awk '{print $1}')


if [ "$type" == "flatpak" ]; then
  app=$(env WAYLAND_DISPLAY='' DISPLAY=:$x zenity $zenityArgs --list \
    --text="Select app to run" \
    --column=app \
    --separator=' ' \
    $(flatpak list --app | awk -F '\t'  '{print $2}'))
elif [ "$type" == "bwrap" ]; then
  app=$(env WAYLAND_DISPLAY='' DISPLAY=:$x zenity $zenityArgs --entry \
    --text="enter command to run")
fi

if [ "$app" == "" ];then
  cleanup
  exit
fi

#mount overlay
if [ "$overlayFolder" != "" ]; then
  mkdir -p "$homeDir"/"$user"/Overlay/upper
  mkdir -p "$homeDir"/"$user"/Overlay/workdir
  fuse-overlayfs -o \
    lowerdir="$overlayFolder",upperdir="$homeDir"/"$user"/Overlay/upper,workdir="$homeDir"/"$user"/Overlay/workdir \
    "$homeDir"/"$user"/Overlay
fi

if [ "$type" == "flatpak" ]; then
  env WAYLAND_DISPLAY="" XDG_SESSION_TYPE=x11 DISPLAY=:$x HOME="$homeDir"/"$user" flatpak run $app
elif [ "$type" == "bwrap" ]; then
  bwrap \
    --die-with-parent \
    --new-session \
    --dev-bind / / \
    --proc /proc \
    --dir /var \
    --dir "$XDG_RUNTIME_DIR" \
    --bind "$XDG_RUNTIME_DIR"/pulse/native "$XDG_RUNTIME_DIR"/pulse/native \
    --tmpfs /tmp \
    --ro-bind /tmp/.X11-unix/X$x /tmp/.X11-unix/X$x \
    --dev-bind $homeDir/$user $HOME \
    --chdir $HOME \
    --clearenv \
    --setenv PATH "$PATH" \
    --setenv DISPLAY ":$x" \
    --setenv HOME "$HOME" \
    --setenv USER "$USER" \
    --setenv USERNAME "$USERNAME" \
    --setenv LANG "$LANG" \
    --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR" \
    --setenv XDG_SESSION_TYPE "$XDG_SESSION_TYPE" \
    --setenv XDG_CURRENT_DESKTOP "$XDG_CURRENT_DESKTOP" \
    dbus-run-session $app
fi
cleanup
