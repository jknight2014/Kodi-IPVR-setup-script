#!/bin/bash
# Script Name: Knight IPVR installer
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
if (whiptail --title "Knight IPVR" --yesno "Version: 0.1 (November 16, 2014) Knight IPVR installation will start soon. Please read the following carefully. The script has been confirmed to work on Ubuntu 14.04. 2. While several testing runs identified no known issues, the author cannot be held accountable for any problems that might occur due to the script. 3. If you did not run this script with sudo, you maybe asked for your root password during installation." 12 78) then
    echo
else
    whiptail --title "ABORT" --infobox "You have aborted. Please try again." 8 78
	exit 0
fi

UNAME=$(whiptail --inputbox "Enter the user you want your scripts to run as. (Case sensitive, Must exist)" 10 50 --title "System Username" 3>&1 1>&2 2>&3)

if [ ! -d "/home/$UNAME" ]; then
  whiptail --msgbox 'Your username was not found. Your user must have a home folder in the "/home" directory' 10 30
  exit 0
fi

USERNAME=$(whiptail --inputbox "Enter the username you want to use to log into your scripts" 10 50 --title "Script Username" 3>&1 1>&2 2>&3)
PASSWORD=$(whiptail --passwordbox "Enter the Password you want to use to log into your scripts" 10 50 --title "Script Password" 3>&1 1>&2 2>&3)
DIR=$(whiptail --inputbox "Enter the  directory where you would like downloads saved. (/home/john would save complete downloads in /home/john/Downloads/Complete" 10 50 /home/$UNAME --title "Storage Directory" 3>&1 1>&2 2>&3)
API=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
USENETUSR=$(whiptail --inputbox "Please enter your Usenet servers Username" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)
USENETPASS=$(whiptail --inputbox "Please enter your Usenet servers Password" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)
USENETHOST=$(whiptail --inputbox "Please enter your Usenet servers Hostname" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)
USENETPORT=$(whiptail --inputbox "Please enter your Usenet servers connection Port" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)
USENETCONN=$(whiptail --inputbox "Please enter the maximum number of connections your server allowes " 10 50 --title "Usenet" 3>&1 1>&2 2>&3)
if (whiptail --title "Usenet" --yesno "Does your usenet server use SSL?" 8 78) then
    USENETSSL=1
else
    USENETSSL=0
fi

INDEXERHOST=$(whiptail --inputbox "Please enter your Newsnab powered Indexers hostname" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)
INDEXERAPI=$(whiptail --inputbox "Please enter your Newsnab powered Indexers API key" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)
INDEXERNAME=$(whiptail --inputbox "Please enter a name for your Newsnab powered Indexer (This can be anything)" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)


function firstroutine {
 SAB=1
}

function secondroutine {
 SONARR=1
}


function thirdroutine {
 CP=1
}

whiptail --title "Test" --checklist --separate-output "Choose which apps you would like installed:" 20 78 15 \
"SABnzbd" "" on \
"Sonarr" "" on \
"CouchPotato" "" on 2>results

while read choice
do
        case $choice in
                SABnzbd) firstroutine
                ;;
                Sonarr) secondroutine
                ;;
                CouchPotato) thirdroutine
                ;;
                *)
                ;;
        esac
done < results

sudo mkdir $DIR/Movies
sudo mkdir $DIR/TVShows
sudo mkdir $DIR/Downloads
sudo mkdir $DIR/Downloads/Complete
sudo mkdir $DIR/Downloads/Incomplete
sudo mkdir $DIR/Downloads/Complete/Movies
sudo mkdir $DIR/Downloads/Complete/TV
sudo chown -R $UNAME:$UNAME $DIR/Movies
sudo chown -R $UNAME:$UNAME $DIR/TVShows
sudo chown -R $UNAME:$UNAME $DIR/Downloads
sudo chmod -R 775 $DIR/Movies
sudo chmod -R 775 $DIR/TVShows
sudo chmod -R 775 $DIR/Downloads
sudo mkdir /home/$UNAME/IPVR
sudo chown -R $UNAME:$UNAME /home/$UNAME/IPVR
sudo chmod -R 775 /home/$UNAME/IPVR
	whiptail --title "Knight IPVR" --infobox "Adding repositories" 8 78
	sudo add-apt-repository -y ppa:jcfp/ppa  >> /home/$UNAME/IPVR-install.log
	sudo add-apt-repository -y ppa:directhex/monoxide >> /home/$UNAME/IPVR-install.log
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC >> /home/$UNAME/IPVR-install.log
	echo "deb http://update.nzbdrone.com/repos/apt/debian master main" | sudo tee -a /etc/apt/sources.list

	whiptail --title "Knight IPVR" --infobox "Updating Packages" 8 78
	sudo apt-get -qq update
if [[ "$SAB" == "1" ]] 
then

	whiptail --title "SABnzbd" --infobox "Installing SABnzbd" 8 78
	sudo apt-get -qq install sabnzbdplus  >> /home/$UNAME/IPVR-install.log

	whiptail --title "SABnzbd" --infobox "Stopping SABnzbd" 8 78
	sleep 2
	sudo killall sabnzbd* >/dev/null 2>&1

	whiptail --title "SABnzbd" --infobox "Removing Standard init scripts" 8 78
	sudo update-rc.d sabnzbdplus remove >> /home/$UNAME/IPVR-install.log

	whiptail --title "SABnzbd" --infobox "Configuring SABnzbd" 8 78
	API=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
	echo "username = "$USERNAME >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "password = "$PASSWORD >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "api_key = "$API >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "complete_dir = "$DIR"/Downloads/Complete" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "download_dir = "$DIR"/Downloads/Incomplete" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "[servers]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "[["$USENETHOST"]]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "username = "$USENETUSR >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "enable = 1" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "name = "$USENETHOST >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "fillserver = 0" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "connections = "$USENETCONN >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "ssl = "$USENETSSL >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "host = "$USENETHOST >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "timeout = 120" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "password = "$USENETPASS >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "optional = 0" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "port = "$USENETPORT >> /home/$UNAME/IPVR/.sabnzbd/config.ini
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
	echo "name = TV" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "script = Default" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo 'newzbin = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "dir = "$DIR"/Downloads/Complete/TVShows" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "[[movies]]" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "priority = -100" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo 'pp = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "name = Movies" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "script = Default" >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo 'newzbin = ""' >> /home/$UNAME/IPVR/.sabnzbd/config.ini
	echo "dir = "$DIR"/Downloads/Complete/Movies" >> /home/$UNAME/IPVR/.sabnzbd/config.ini


	whiptail --title "SABnzbd" --infobox "Adding SABnzbd upstart config" 8 78
	sleep 2
	echo 'description "Upstart Script to run sabnzbd as a service on Ubuntu/Debian based systems"' >> /etc/init/sabnzbd.conf
	echo "setuid "$UNAME >> /etc/init/sabnzbd.conf
	echo "setgid "$UNAME >> /etc/init/sabnzbd.conf
	echo 'start on runlevel [2345]' >> /etc/init/sabnzbd.conf
	echo 'stop on runlevel [016]' >> /etc/init/sabnzbd.conf
	echo 'respawn limit 10 10' >> /etc/init/sabnzbd.conf
	echo "exec sabnzbdplus -f /home/"$UNAME"/IPVR/.sabnzbd/config.ini -s 0.0.0.0:8085 -b 0 --permissions 775" >> /etc/init/sabnzbd.conf

	whiptail --infobox "SABnzbd has finished installing. Continuing with Sonarr install." 12 78 --title "FINISHED"
fi

if [[ "$SONARR" == "1" ]] 
then

	whiptail --title "SONARR" --infobox "Installing mono..." 8 78
	sudo apt-get -qq install mono-complete  >> /home/$UNAME/IPVR-install.log

	whiptail --title "SONARR" --infobox "Checking for previous versions of NZBget/Sonarr..." 8 78
	sleep 2
	sudo killall sonarr* >/dev/null 2>&1
	sudo killall nzbget* >/dev/null 2>&1

	whiptail --title "SONARR" --infobox "Downloading latest Sonarr..." 8 78
	sleep 2
	sudo apt-get -qq install nzbdrone >> /home/$UNAME/IPVR-install.log

	sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "UPDATE Config SET value = "$UNAME" WHERE Key = chownuser"
	sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "UPDATE Config SET value = "$UNAME" WHERE Key = chowngroup"
	sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "UPDATE Config SET value = "$DIR"/Downloads/Complete/TV WHERE Key = downloadedepisodesfolder"
	sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "UPDATE Config SET value = "$UNAME" WHERE Key = chowngroup"
	sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "INSERT INTO DownloadClients VALUES (NULL,'1','Sabnzbd,'Sabnzbd','{"host": "localhost", "port": 8085, "apiKey": "$API", "username": "$USERNAME", "password": "$PASSWORD", "tvCategory": "tv", "recentTvPriority": 1, "olderTvPriority": -100, "useSsl": false}', 'SabnzbdSettings')"
	sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "INSERT INTO Indexers VALUES (NULL,'"$INDEXNAME"','Newznab,'{ "url": "$INDEXHOST", "apiKey": "$INDEXAPI", "categories": [   5030,   5040 ], "animeCategories": []  }','NewznabSettings','1','1')"
	sqlite3 /home/$UNAME/.config/NzbDrone/nzbdrone.db "INSERT INTO RootFolders VALUES (NULL,'"$DIR"/TVShows')"

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

	whiptail --title "SONARR" --infobox "Creating new default and init scripts..." 8 78
	sleep 2
	echo 'description "Upstart Script to run sonarr as a service on Ubuntu/Debian based systems"' >> /etc/init/sonarr.conf
	echo "setuid "$UNAME >> /etc/init/sonarr.conf
	echo 'env DIR=/opt/NzbDrone' >> /etc/init/sonarr.conf
	echo 'setgid nogroup' >> /etc/init/sonarr.conf
	echo 'start on runlevel [2345]' >> /etc/init/sonarr.conf
	echo 'stop on runlevel [016]' >> /etc/init/sonarr.conf
	echo 'respawn limit 10 10' >> /etc/init/sonarr.conf
	echo 'exec mono $DIR/NzbDrone.exe' >> /etc/init/sonarr.conf
	 

	whiptail --infobox "Sonarr has finished installing. Continuing with CouchPotato install." 12 78 --title "FINISHED"
fi
if [[ "$CP" == "1" ]] 
then

	whiptail --title "COUCHPOTATO" --infobox "Installing Git and Python" 8 78  
	sudo apt-get -qq install git-core python  >> /home/$UNAME/IPVR-install.log


	whiptail --title "COUCHPOTATO" --infobox "Killing and version of couchpotato currently running" 8 78  
	sleep 2
	sudo killall couchpotato* >/dev/null 2>&1


	whiptail --title "COUCHPOTATO" --infobox "Downloading the latest version of CouchPotato" 8 78  
	sleep 2
	mkdir /home/$UNAME/IPVR >> /home/$UNAME/IPVR-install.log
	cd /home/$UNAME/IPVR >> /home/$UNAME/IPVR-install.log
	git clone git://github.com/RuudBurger/CouchPotatoServer.git .couchpotato >> /home/$UNAME/IPVR-install.log

	whiptail --title "COUCHPOTATO" --infobox "Installing upstart configurations" 8 78  
	sleep 2
	echo 'description "Upstart Script to run couchpotato as a service on Ubuntu/Debian based systems"' >> /etc/init/couchpotato.conf
	echo "setuid "$UNAME >> /etc/init/couchpotato.conf
	echo "setgid "$UNAME >> /etc/init/couchpotato.conf
	echo 'start on runlevel [2345]' >> /etc/init/couchpotato.conf
	echo 'stop on runlevel [016]' >> /etc/init/couchpotato.conf
	echo 'respawn limit 10 10' >> /etc/init/couchpotato.conf
	echo "exec  /home/"$UNAME"/.couchpotato/CouchPotato.py --config_file /home/xbmc/.couchpotato/settings.conf --data_dir /home/xbmc/.couchpotato/" >> /etc/init/couchpotato.conf

	echo "[core]" > /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "api_key = "$API >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = "$USERNAME >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "ssl_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "ssl_cert = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "data_dir = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "permission_folder = 0755" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "development = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "url_base = /couchpotato" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "debug = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "launch_browser = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = "$PASSWORD >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "port = 5050" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "permission_file = 0755" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "show_wizard = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[download_providers]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[updater]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "notification = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "git_command = git" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automatic = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[automation]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "rating = 7.0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "votes = 1000" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "hour = 12" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "required_genres = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "year = 2011" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "ignored_genres = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[manage]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "startup_scan = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "library_refresh_interval = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "cleanup = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "library = "$DIR"/Movies/" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[renamer]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "nfo_name = <filename>.orig.<ext>" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "from = "$DIR"/Downloads/Complete/Movies/" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "force_every = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "move_leftover = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "to = "$DIR"/Movies/" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "file_name = <thename><cd>.<ext>" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "next_on_failed = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "default_file_action = move" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "unrar = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "rename_nfo = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "cleanup = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "separator = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "folder_name = <namethe> (<year>)" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "run_every = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "foldersep = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "file_action = move" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "ntfs_permission = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "unrar_path = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "unrar_modify_date = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "check_space = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[subtitle]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "languages = en" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "force = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[trailer]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "quality = 720p" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "name = <filename>-trailer" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[blackhole]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "directory = /home/$UNAME" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "create_subdir = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "use_for = both" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[deluge]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "delete_failed = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "completed_directory = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "label = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "paused = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "host = localhost:58846" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "delete_files = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "directory = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "remove_complete = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[nzbget]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = admin" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "category = Movies" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "delete_failed = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "priority = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "ssl = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "host = localhost:6789" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = "$PASSWORD >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[nzbvortex]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "group = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "delete_failed = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "manual = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "host = https://localhost:4321" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[pneumatic]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "directory = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[qbittorrent]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "paused = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "host = http://localhost:8080/" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "delete_files = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "remove_complete = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[rtorrent]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "rpc_url = RPC2" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "label = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "paused = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "ssl = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "host = localhost:80" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "delete_files = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "directory = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "remove_complete = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[sabnzbd]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "category = Movies" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "delete_failed = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "manual = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "priority = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "ssl = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "host = localhost:8085" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "remove_complete = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "api_key = "$API >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[synology]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "destination = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "host = localhost:5000" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "use_for = both" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[transmission]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = admin" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "stalled_as_failed = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "delete_failed = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "rpc_url = transmission" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "paused = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "host = http://localhost:9091" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "delete_files = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "directory = /data/Downloads/Complete/Movies/" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "remove_complete = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = "$PASSWORD >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[utorrent]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "delete_failed = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "manual = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "label = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "paused = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "host = localhost:8000" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "delete_files = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "remove_complete = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[notification_providers]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[boxcar2]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "token = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[email]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "starttls = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "smtp_pass = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "from = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "to = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "smtp_port = 25" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "smtp_server = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "smtp_user = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "ssl = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[growl]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "on_snatch = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "hostname = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "port = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[nmj]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "host = localhost" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "mount = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "database = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[notifymyandroid]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "priority = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "dev_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[notifymywp]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "priority = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "dev_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[plex]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "clients = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "media_server = localhost" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[prowl]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "priority = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[pushalot]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "auth_token = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "important = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "silent = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[pushbullet]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "devices = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[pushover]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "sound = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "user_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "priority = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "api_token = YkxHMYDZp285L265L3IwH3LmzkTaCy" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[synoindex]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[toasty]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[trakt]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "remove_watchlist_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "notification_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[twitter]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "screen_name = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "access_token_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "mention = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "access_token_secret = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "direct_message = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[$UNAME]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = "$USERNAME >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "on_snatch = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "force_full_scan = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "only_first = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "remote_dir_scan = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "host = localhost:8080" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = "$PASSWORD >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_disc_art_name = disc.png" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_extra_thumbs_name = extrathumbs/thumb<i>.jpg" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_thumbnail = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_extra_fanart = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_logo = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_landscape_name = landscape.jpg" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_nfo_name = %s.nfo" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_banner_name = banner.jpg" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_landscape = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_extra_fanart_name = extrafanart/extrafanart<i>.jpg" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_nfo = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_fanart = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_thumbnail_name = %s.tbn" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_url_only = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_fanart_name = %s-fanart.jpg" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_logo_name = logo.png" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_banner = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_clear_art = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_clear_art_name = clearart.png" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_extra_thumbs = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_disc_art = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[xmpp]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "on_snatch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "hostname = talk.google.com" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "to = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "port = 5222" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[nzb_providers]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[binsearch]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[newznab]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "use = 1,0,0,0,0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 10,0,0,0,0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "host = "$INDEXHOST"api.nzb.su,api.dognzb.cr,nzbs.org,https://api.nzbgeek.info" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "custom_tag = ,,,," >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "api_key = "$INDEXAPI",,,," >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[nzbclub]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[omgwtfnzbs]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "api_key = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[torrent_providers]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[awesomehd]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "only_internal = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "passkey = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "favor = both" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "prefer_internal = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[bithdtv]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[bitsoup]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[hdbits]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "passkey = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[ilovetorrents]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[iptorrents]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "freeleech = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[kickasstorrents]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "domain = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "only_verified = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[passthepopcorn]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "domain = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "passkey = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "prefer_scene = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "prefer_golden = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "require_approval = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "prefer_freeleech = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[sceneaccess]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[thepiratebay]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "domain = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = .5" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[torrentbytes]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[torrentday]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[torrentleech]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 20" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[torrentpotato]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "use = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "name = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "host = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "pass_key = ," >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[torrentshack]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "scene_only = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "password = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[torrentz]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "verified_only = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "minimal_seeds = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[yify]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_time = 40" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "domain = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "enabled = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "seed_ratio = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "extra_score = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[searcher]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "preferred_method = nzb" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "required_words = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "ignored_words = german, dutch, french, truefrench, danish, swedish, spanish, italian, korean, dubbed, swesub, korsub, dksubs, vain" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "preferred_words = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[nzb]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "retention = 1500" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[torrent]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "minimum_seeders = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[charts]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "hide_wanted = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "hide_library = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "max_items = 5" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[automation_providers]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[bluray]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "chart_display_enabled = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "backlog = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[flixster]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_ids_use = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_ids = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[goodfilms]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_username = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[imdb]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_charts_top250 = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "chart_display_boxoffice = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "chart_display_top250 = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "chart_display_rentals = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_urls_use = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_urls = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_providers_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_charts_rentals = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "chart_display_theater = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_charts_theater = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "chart_display_enabled = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_charts_boxoffice = True" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[itunes]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_urls_use = ," >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_urls = https://itunes.apple.com/rss/topmovies/limit=25/xml," >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[kinepolis]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[letterboxd]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_urls_use = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_urls = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[moviemeter]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[moviesio]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_urls_use = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_urls = " >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[popularmovies]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[rottentomatoes]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "tomatometer_percent = 80" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_urls_use = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "automation_urls = http://www.rottentomatoes.com/syndication/rss/in_theaters.xml" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[themoviedb]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "api_key = 9b939aee0aaafc12a65bf448e4af9543" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[mediabrowser]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[sonyps3]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[windowsmediacenter]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "meta_enabled = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "[moviesearcher]" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "cron_day = *" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "cron_hour = */6" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "cron_minute = 53" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "always_search = False" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "run_on_launch = 0" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "search_on_add = 1" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
	echo "" >> /home/$UNAME/IPVR/.couchpotato/settings.conf 
fi

whiptail --msgbox "All done.  Your IPVR should start within 10-20 seconds If not you can start it using (sudo start sabnzbd sonarr couchpotato) command.  Then open http://localhost:#PORT in your browser. Replace #PORT with the port of the program you want to access. Couchpotato = 5050 Sonarr = 8989 SABnzbd = 8085. Replace localhost with your server IP for remote systems." 15 78 --title "FINISHED"


sudo start sabnzbd
sudo start sonarr
sudo start couchpotato
