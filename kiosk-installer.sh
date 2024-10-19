#!/bin/bash

# be new
apt-get update

# get software
apt-get install \
    unclutter \
    xorg \
    midori \
    matchbox \
    lightdm \
    locales \
    -y

# dir
#mkdir -p /home/kiosk/.config/openbox
mkdir -p /home/kiosk/.matchbox

# create group
groupadd kiosk

# create user if not exists
id -u kiosk &>/dev/null || useradd -m kiosk -g kiosk -s /bin/bash 

# rights
chown -R kiosk:kiosk /home/kiosk

# remove virtual consoles
if [ -e "/etc/X11/xorg.conf" ]; then
  mv /etc/X11/xorg.conf /etc/X11/xorg.conf.backup
fi
cat > /etc/X11/xorg.conf << EOF
Section "ServerFlags"
    Option "DontVTSwitch" "true"
EndSection
EOF

# create config
if [ -e "/etc/lightdm/lightdm.conf" ]; then
  mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.backup
fi
cat > /etc/lightdm/lightdm.conf << EOF
[SeatDefaults]
autologin-user=kiosk
user-session=matchbox
EOF

# create autostart
if [ -e "/home/kiosk/.matchbox/session" ]; then
  mv /home/kiosk/.matchbox/session /home/kiosk/.matchbox/session.backup
fi
cat > /home/kiosk/.matchbox/session << EOF
#!/bin/bash

#unclutter -idle 0.1 -grab -root &

while :
do
  xrandr --auto
  midori -e Fullscreen -a https://openweathermap.org/city/2657896
  sleep 5
done &
EOF

echo "Done!"
