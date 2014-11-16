#!/bin/bash
# Script Name: Knight Sonarr installer
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
echo 'Version: 0.1 (November 16, 2014)'
echo '--->Sonarr installation will start soon. Please read the following carefully.'
echo '1. The script has been confirmed to work on Ubuntu and other Ubuntu based distros, including Mint, Kubuntu, Lubuntu, and Xubuntu.'
echo '2. While several testing runs identified no known issues, www.htpcBeginner.com or the author cannot be held accountable for any problems that might occur due to the script.'
echo '3. If you did not run this script with sudo, you maybe asked for your root password during installation.'

echo

read -p "Press y/Y and enter to AGREE and continue with the installation or any other key to exit: "
RESP=${REPLY,,}
if [ "$RESP" != "y" ]
then
	echo 'You can rerun the installer at any time. '
	echo
	exit 0
fi

echo 

read -p "Enter the username of the user you want to run Sonarr as. Typically, this is your username (IMPORTANT! Ensure correct spelling and case): "
UNAME=${REPLY,,}

if [ ! -d "/home/$UNAME" ]; then
  echo 'Your username was not found. Your user must have a home folder in the "/home" directory'
  echo
  exit 0
fi

echo

echo '--->Adding Repository...'
sudo add-apt-repository ppa:directhex/monoxide
echo

echo '--->Updating Packages...'
sudo apt-get update
echo

echo '--->Installing mono...'
sudo apt-get -y install mono-complete
echo

echo '--->Checking for previous versions of NZBget/Sonarr...'
sleep 2
sudo killall sonarr* >/dev/null 2>&1
sudo killall nzbget* >/dev/null 2>&1
echo

echo '--->Downloading latest Sonarr...'
sleep 2
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC
echo "deb http://update.nzbdrone.com/repos/apt/debian master main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install nzbdrone
echo

echo '--->Creating new default and init scripts...'
sleep 2
echo 'description "Upstart Script to run sonarr as a service on Ubuntu/Debian based systems"' >> /etc/init/sonarr.conf
echo "setuid="$UNAME >> /etc/init/sonarr.conf
echo 'env DIR=/opt/NzbDrone' >> /etc/init/sonarr.conf
echo 'setgid nogroup' >> /etc/init/sonarr.conf
echo 'start on runlevel [2345]' >> /etc/init/sonarr.conf
echo 'stop on runlevel [016]' >> /etc/init/sonarr.conf
echo 'respawn limit 10 10' >> /etc/init/sonarr.conf
echo 'exec mono $DIR/NzbDrone.exe' >> /etc/init/sonarr.conf
echo

echo '--->All done.'
echo 'Sonarr should start within 10-20 seconds'
echo 'If not you can start it using "sudo start sonarr" command.'
echo 'Then open http://localhost:8989 in your browser. Replace localhost with your server IP for remote systems.'
echo
echo '***If this script worked for you, please visit http://www.htpcBeginner.com and like/follow us.'
echo
sudo start sonarr