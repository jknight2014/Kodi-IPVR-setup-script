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
INDEXERHOST=$(whiptail --inputbox "Please enter your Newsnab powered Indexers hostname" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)
INDEXERAPI=$(whiptail --inputbox "Please enter your Newsnab powered Indexers API key" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)
INDEXERNAME=$(whiptail --inputbox "Please enter a name for your Newsnab powered Indexer (This can be anything)" 10 50 --title "Usenet" 3>&1 1>&2 2>&3)

if (whiptail --title "Usenet" --yesno "Does your usenet server use SSL?" 8 78) then
    USENETSSL=1
else
    USENETSSL=0
fi
USENETCONN=$(whiptail --inputbox "Please enter the maximum number of connections your server allowes " 10 50 --title "Usenet" 3>&1 1>&2 2>&3)

echo $UNAME" and "$USERNAME" and "$PASSWORD" and "$DIR" and "$API
