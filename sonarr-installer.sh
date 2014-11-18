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

if (whiptail --title "SONARR" --yesno "Version: 0.1 (November 16, 2014) --->SONARR installation will start soon. Please read the following carefully. The script has been confirmed to work on Ubuntu and other Ubuntu based distros, including Mint, Kubuntu, Lubuntu, and Xubuntu. 2. While several testing runs identified no known issues, www.htpcBeginner.com or the author cannot be held accountable for any problems that might occur due to the script. 3. If you did not run this script with sudo, you maybe asked for your root password during installation." 8 78) then
    echo
else
    whiptail --title "ABORT" --msgbox "You have aborted. Please try again." 8 78
	exit 0
fi


UNAME=$(whiptail --inputbox "Enter the user you want SONARR to run as. (Case sensitive, Must exist)" 10 50 --title "System Username" 3>&1 1>&2 2>&3)

if [ ! -d "/home/$UNAME" ]; then
  whiptail --title "ABORT" --msgbox "The user you entered does not exist or does not have a home directory" 8 78  
  exit 0
fi


whiptail --title "SONARR" --msgbox "Adding Repository..." 8 78
sudo add-apt-repository ppa:directhex/monoxide

whiptail --title "SONARR" --msgbox "Updating Packages..." 8 78
sudo apt-get update

whiptail --title "SONARR" --msgbox "Installing mono..." 8 78
sudo apt-get -y install mono-complete

whiptail --title "SONARR" --msgbox "Checking for previous versions of NZBget/Sonarr..." 8 78
sleep 2
sudo killall sonarr* >/dev/null 2>&1
sudo killall nzbget* >/dev/null 2>&1

whiptail --title "SONARR" --msgbox "Downloading latest Sonarr..." 8 78
sleep 2
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC
echo "deb http://update.nzbdrone.com/repos/apt/debian master main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install nzbdrone

sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "UPDATE Config SET value = "$UNAME" WHERE Key = chownuser"
sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "UPDATE Config SET value = "$UNAME" WHERE Key = chowngroup"
sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "UPDATE Config SET value = "$DIR"/Downloads/Complete/TV WHERE Key = downloadedepisodesfolder"
sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "UPDATE Config SET value = "$UNAME" WHERE Key = chowngroup"
sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "INSERT INTO DownloadClients VALUES (NULL,'1','Sabnzbd,'Sabnzbd','{"host": "localhost", "port": 8085, "apiKey": "$API", "username": "$USERNAME", "password": "$PASSWORD", "tvCategory": "tv", "recentTvPriority": 1, "olderTvPriority": -100, "useSsl": false}', 'SabnzbdSettings')"
sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "INSERT INTO Indexers VALUES (NULL,"$INDEXNAME",'Newznab,'{ "url": "$INDEXHOST", "apiKey": "$INDEXAPI", "categories": [   5030,   5040 ], "animeCategories": []  }','NewznabSettings','1','1')"

echo "<?xml version="1.0" encoding="utf-8" standalone="yes"?>" > /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "<Config>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  <Port>8989</Port>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  <SslPort>9898</SslPort>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  <EnableSsl>False</EnableSsl>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  <LaunchBrowser>False</LaunchBrowser>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  <ApiKey>32cc1aa3d523445c8612bd5d130ba74a</ApiKey>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  <AuthenticationEnabled>True</AuthenticationEnabled>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  <Branch>torrents</Branch>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  <Username>"$USERNAME"</Username>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  <Password>"$PASSWORD"</Password>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  <LogLevel>Trace</LogLevel>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  <SslCertHash>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  </SslCertHash>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  <UrlBase>sonarr</UrlBase>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  <UpdateMechanism>BuiltIn</UpdateMechanism>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "  <UpdateAutomatically>True</UpdateAutomatically>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 
echo "</Config>" >> /home/$UNAME/.config/NzbDrone/nzbdrone.db 

whiptail --title "SONARR" --msgbox "Creating new default and init scripts..." 8 78
sleep 2
echo 'description "Upstart Script to run sonarr as a service on Ubuntu/Debian based systems"' >> /etc/init/sonarr.conf
echo "setuid "$UNAME >> /etc/init/sonarr.conf
echo 'env DIR=/opt/NzbDrone' >> /etc/init/sonarr.conf
echo 'setgid nogroup' >> /etc/init/sonarr.conf
echo 'start on runlevel [2345]' >> /etc/init/sonarr.conf
echo 'stop on runlevel [016]' >> /etc/init/sonarr.conf
echo 'respawn limit 10 10' >> /etc/init/sonarr.conf
echo 'exec mono $DIR/NzbDrone.exe' >> /etc/init/sonarr.conf
 
whiptail --title "COUCHPOTATO" --msgbox "All done.  SONARR should start within 10-20 seconds  If not you can start it using (sudo start sonarr) command.  Then open http://localhost:8989 in your browser. Replace localhost with your server IP for remote systems.   ***If this script worked for you, please visit http://www.htpcBeginner.com and like/follow us." 12 78 

sudo start sonarr