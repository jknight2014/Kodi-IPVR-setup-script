#!/bin/bash
# Script Name: Knight sabnzbd installer
# Author: Joe Knight
# Version: 0.1 initial build
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# DO NOT EDIT ANYTHING UNLESS YOU KNOW WHAT YOU ARE DOING.
clear
if (whiptail --title "SABnzbd" --yesno "Version: 0.1 (November 16, 2014) --->SABnzbd installation will start soon. Please read the following carefully. The script has been confirmed to work on Ubuntu and other Ubuntu based distros, including Mint, Kubuntu, Lubuntu, and Xubuntu. 2. While several testing runs identified no known issues, www.htpcBeginner.com or the author cannot be held accountable for any problems that might occur due to the script. 3. If you did not run this script with sudo, you maybe asked for your root password during installation." 8 78) then
    echo
else
    whiptail --title "ABORT" --msgbox "You have aborted. Please try again." 8 78
	exit 0
fi
UNAME=$(whiptail --inputbox "Enter the user you want your scripts to run as. (Case sensitive, Must exist)" 10 50 --title "System Username" 3>&1 1>&2 2>&3)

if [ ! -d "/home/$UNAME" ]; then
  whiptail --msgbox 'Your username was not found. Your user must have a home folder in the "/home" directory' 10 30
  exit 0
fi
USERNAME=$(whiptail --inputbox "Enter the username you want to use to log into your scripts" 10 50 --title "Script Username" 3>&1 1>&2 2>&3)
PASSWORD=$(whiptail --inputbox "Enter the Password you want to use to log into your scripts" 10 50 --title "Script Password" 3>&1 1>&2 2>&3)
DIR=$(whiptail --passwordbox "Enter the  directory where you would like downloads saved. (/home/john would save complete downloads in /home/john/Downloads/Complete" 10 50 /home/$UNAME --title "Storage Directory" 3>&1 1>&2 2>&3)
API=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
USENETUSR=$(whiptail --inputbox "Please enter your Usenet servers Username" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)
USENETPASS=$(whiptail --inputbox "Please enter your Usenet servers Password" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)
USENETHOST=$(whiptail --inputbox "Please enter your Usenet servers Hostname" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)
USENETPORT=$(whiptail --inputbox "Please enter your Usenet servers connection Port" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)
if (whiptail --title "Usenet" --yesno "Does your usenet server use SSL?" 8 78) then
    USENETSSL=1
else
    USENETSSL=0
fi
USENETCONN=$(whiptail --inputbox "Please enter the maximum number of connections your server allowes " 10 50 --title "Usenet" 3>&1 1>&2 2>&3)

whiptail --title "SABnzbd" --msgbox "Adding SABnzbd repository" 8 78
sudo add-apt-repository ppa:jcfp/ppa
 

whiptail --title "SABnzbd" --msgbox "Updating Packages" 8 78
sudo apt-get update


whiptail --title "SABnzbd" --msgbox "Installing SABnzbd" 8 78
sudo apt-get install sabnzbdplus

whiptail --title "SABnzbd" --msgbox "Stopping SABnzbd" 8 78
sleep 2
sudo killall sabnzbd* >/dev/null 2>&1

whiptail --title "SABnzbd" --msgbox "Removing Standard init scripts" 8 78
update-rc.d sabnzbdplus remove

whiptail --title "SABnzbd" --msgbox "Configuring SABnzbd" 8 78
API=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
echo "username = "$USER >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "password = "$PASS >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "api_key = "$API >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "complete_dir = "$DIR"/Downloads/Complete" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "download_dir = "$DIR"/Downloads/Incomplete" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "[servers]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "[["$SERVER"]]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "username = "$USENETUSR >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "enable = 1" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "name = "$SERVER >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "fillserver = 0" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "connections = "$CONNECTIONS >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "ssl = "$SSL >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "host = "$SERVER >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "timeout = 120" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "password = "$USENETPASS >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "optional = 0" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "port = "$PORT >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "retention = 0" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "[categories]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "[[*]]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "priority = 0" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "pp = 3" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "name = *" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "script = None" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo 'newzbin = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo 'dir = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "[[tv]]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "priority = -100" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo 'pp = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "name = tv" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "script = Default" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo 'newzbin = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "dir = "$DIR"/Downloads/Complete/TV" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "[[movies]]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "priority = -100" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo 'pp = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "name = movies" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "script = Default" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo 'newzbin = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
echo "dir = "$DIR"/Downloads/Complete/Movie" >> /home/$UNAME/IPVR/.sabnzbd/config.ini


whiptail --title "SABnzbd" --msgbox "Adding SABnzbd upstart config" 8 78
sleep 2
echo 'description "Upstart Script to run sabnzbd as a service on Ubuntu/Debian based systems"' >> /etc/init/sabnzbd.conf
echo "setuid "$UNAME >> /etc/init/sabnzbd.conf
echo "setgid "$UNAME >> /etc/init/sabnzbd.conf
echo 'start on runlevel [2345]' >> /etc/init/sabnzbd.conf
echo 'stop on runlevel [016]' >> /etc/init/sabnzbd.conf
echo 'respawn limit 10 10' >> /etc/init/sabnzbd.conf
echo "exec sabnzbdplus -f /home/"$UNAME"/IPVR/.sabnzbd/config.ini -s 0.0.0.0:8085 -b 0 --permissions 775 "$PARM >> /etc/init/sabnzbd.conf

whiptail --msgbox "All done.  SABnzbd should start within 10-20 seconds If not you can start it using (sudo start sabnzbd) command.  Then open http://localhost:5050 in your browser. Replace localhost with your server IP for remote systems.  ***If this script worked for you, please visit http://www.htpcBeginner.com and like/follow us." 12 78 --title "FINISHED"

sudo start sabnzbd