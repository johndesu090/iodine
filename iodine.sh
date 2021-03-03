#!/bin/bash
# JohnFordTV's Iodine DNS Premium Script
# © Github.com/johndesu090
# Official Repository: https://github.com/johndesu090/
# For Updates, Suggestions, and Bug Reports, Join to my Messenger Groupchat(VPS Owners): https://m.me/join/AbbHxIHfrY9SmoBO
# For Donations, Im accepting prepaid loads or GCash transactions:
# Smart: 09206200840
# Facebook: https://fb.me/johndesu090

#############################
#############################
# Variables (Can be changed depends on your preferred values)

# Script name
MyScriptName='JohnFordTV-SlowDNS [Iodine]'

# Your SSH Banner
SSH_Banner='https://www.dropbox.com/s/01jed4dmaq7cu8b/issue.net'

# Dropbear Ports
Dropbear_Port1='550'
Dropbear_Port2='445'

# OpenSSH Ports
SSH_Port1='22'
SSH_Port2='143'

# Server local time
MyVPS_Time='Asia/Manila'
#############################

#############################
#############################
## All function used for this script
#############################
## WARNING: Do not modify or edit anything
## if you did'nt know what to do.
## This part is too sensitive.
#############################
#############################

function InstUpdates(){
 export DEBIAN_FRONTEND=noninteractive
 apt-get update
 apt-get upgrade -y
 
 # Removing some firewall tools that may affect other services
 apt-get remove --purge ufw firewalld -y

 
 # Installing some important machine essentials
 apt-get install nano wget curl zip unzip tar gzip p7zip-full bc make gcc gcc+ zlib1g-dev rc openssl cron net-tools dnsutils dos2unix screen bzip2 psmisc lsof ccrypt -y
 
 # Now installing all our wanted services
 apt-get install gnupg tcpdump grepcidr dropbear screen ca-certificates ruby apt-transport-https lsb-release -y

 # Installing all required packages to install Webmin
 apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python dbus libxml-parser-perl -y
 apt-get install shared-mime-info jq fail2ban -y

 
 # Installing a text colorizer
 gem install lolcat

 # Trying to remove obsolette packages after installation
 apt-get autoremove -y
 
 
 # Installing Latest Webmin
 rm -rf /etc/apt/sources.list.d/webmin*
 echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list
 echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >> /etc/apt/sources.list.d/webmin.list
 wget -qO - http://www.webmin.com/jcameron-key.asc|apt-key add -
 apt-get update
 apt-get install webmin -y
}

function InstWebmin(){

 # Configuring webmin server config to use only http instead of https
 sed -i 's|ssl=1|ssl=0|g' /etc/webmin/miniserv.conf
 
 # Then restart to take effect
 systemctl restart webmin
}

function InstSSH(){
 # Removing some duplicated sshd server configs
 rm -f /etc/ssh/sshd_config*
 
 # Creating a SSH server config using cat eof tricks
 cat <<'MySSHConfig' > /etc/ssh/sshd_config
# My OpenSSH Server config
Port myPORT1
Port myPORT2
AddressFamily inet
ListenAddress 0.0.0.0
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
PermitRootLogin yes
MaxSessions 1024
Compression yes
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
ClientAliveInterval 240
ClientAliveCountMax 2
UseDNS no
Banner /etc/jftvban
AcceptEnv LANG LC_*
Subsystem   sftp  /usr/lib/openssh/sftp-server
MySSHConfig

 # Now we'll put our ssh ports inside of sshd_config
 sed -i "s|myPORT1|$SSH_Port1|g" /etc/ssh/sshd_config
 sed -i "s|myPORT2|$SSH_Port2|g" /etc/ssh/sshd_config

 # Download our SSH Banner
 rm -f /etc/banner
 rm -f /etc/jftvban
 wget -qO /etc/jftvban "$SSH_Banner"
 dos2unix -q /etc/jftvban

 # My workaround code to remove `BAD Password error` from passwd command, it will fix password-related error on their ssh accounts.
 sed -i '/password\s*requisite\s*pam_cracklib.s.*/d' /etc/pam.d/common-password
 sed -i 's/use_authtok //g' /etc/pam.d/common-password

 # Some command to identify null shells when you tunnel through SSH or using Stunnel, it will fix user/pass authentication error on HTTP Injector, KPN Tunnel, eProxy, SVI, HTTP Proxy Injector etc ssh/ssl tunneling apps.
 sed -i '/\/bin\/false/d' /etc/shells
 sed -i '/\/usr\/bin\/nologin/d' /etc/shells
 echo '/bin/false' >> /etc/shells
 echo '/usr/bin/nologin' >> /etc/shells
 
 # Restarting openssh service
 systemctl restart ssh
 
 # Removing some duplicate config file
 rm -rf /etc/default/dropbear*
 
 # creating dropbear config using cat eof tricks
 cat <<'MyDropbear' > /etc/default/dropbear
# My Dropbear Config
NO_START=0
DROPBEAR_PORT=PORT01
DROPBEAR_EXTRA_ARGS="-p PORT02"
DROPBEAR_BANNER="/etc/jftvban"
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"
DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"
DROPBEAR_RECEIVE_WINDOW=65536
MyDropbear

 # Now changing our desired dropbear ports
 sed -i "s|PORT01|$Dropbear_Port1|g" /etc/default/dropbear
 sed -i "s|PORT02|$Dropbear_Port2|g" /etc/default/dropbear
 
 # Enable IP Forwarding
 echo 1 > /proc/sys/net/ipv4/ip_forward
 
 # Restarting dropbear service
 systemctl restart dropbear
}

function ip_address(){
  local IP="$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )"
  [ -z "${IP}" ] && IP="$( wget -qO- -t1 -T2 ipv4.icanhazip.com )"
  [ -z "${IP}" ] && IP="$( wget -qO- -t1 -T2 ipinfo.io/ip )"
  [ ! -z "${IP}" ] && echo "${IP}" || echo
} 
IPADDR="$(ip_address)"

function InstSlowdns(){

 # Installing SlowDNS Dependencies
 cd
 wget http://www.magictunnel.net/downloads/iodine-0.6.0-rc1-android.tar.gz
 tar xzvf iodine-0.6.0-rc1-android.tar.gz
 cd iodine-0.6.0-rc1-android
 make
 make install
 cd
 
 # Restore IPtables rules
 wget -O /etc/iptables.rules "https://raw.githubusercontent.com/johndesu090/iodine/master/iptables.up.rules"
 iptables-restore < /etc/iptables.rules
 
}

function ScriptMessage(){
 echo -e " $MyScriptName"  | lolcat
 echo -e ""
 echo -e " https://fb.com/johndesu090"
 echo -e "[GCASH] 09206200840 [PAYONEER] admin@johnfordtv.tech"
 echo -e ""
}

#############################################
#############################################
########## Installation Process##############
#############################################
## WARNING: Do not modify or edit anything
## if you did'nt know what to do.
## This part is too sensitive.
#############################################
#############################################


# First thing to do is check if this machine is Debian
 source /etc/os-release
if [[ "$ID" != 'debian' ]]; then
 ScriptMessage
 echo -e "[\e[1;31mError\e[0m] This script is for Debian only, exiting..." 
 exit 1
fi

 # Now check if our machine is in root user, if not, this script exits
 # If you're on sudo user, run `sudo su -` first before running this script
 if [[ $EUID -ne 0 ]];then
 ScriptMessage
 echo -e "[\e[1;31mError\e[0m] This script must be run as root, exiting..."
 exit 1
fi

 # (For OpenVPN) Checking it this machine have TUN Module, this is the tunneling interface of OpenVPN server
 if [[ ! -e /dev/net/tun ]]; then
 echo -e "[\e[1;31mError\e[0m] You cant use this script without TUN Module installed/embedded in your machine, file a support ticket to your machine admin about this matter"
 echo -e "[\e[1;31m-\e[0m] Script is now exiting..."
 exit 1
fi

 # Begin Installation by Updating and Upgrading machine and then Installing all our wanted packages/services to be install.
 sleep 1
 InstUpdates
 ScriptMessage
 sleep 10
 
 # Configure OpenSSH and Dropbear
 echo -e "Configuring ssh... "  | lolcat
 InstSSH
 
 # Configure Stunnel
 echo -e "Configuring SlowDNS (Andiodine)... "  | lolcat
 sleep 10
 InstSlowdns
 
 # Configure Webmin
 echo -e "Configuring webmin..." | lolcat
 sleep 3
 InstWebmin
 
 # Setting server local time
 ln -fs /usr/share/zoneinfo/$MyVPS_Time /etc/localtime
 
 clear
 cd ~
 
 #Install Figlet
apt-get install figlet
apt-get install cowsay fortune-mod -y
ln -s /usr/games/cowsay /bin
ln -s /usr/games/fortune /bin
echo "clear" >> .bashrc
echo 'echo -e ""' >> .bashrc
echo 'echo -e ""' >> .bashrc
echo 'cowsay -f dragon "WELCOME MY BOSS." | lolcat' >> .bashrc
echo 'figlet -k JOHNFORDTV' >> .bashrc
echo 'echo -e ""' >> .bashrc
echo 'echo -e "     =========================================================" | lolcat' >> .bashrc
echo 'echo -e "     *                 WELCOME TO SLOWDNS SERVER              *" | lolcat' >> .bashrc
echo 'echo -e "     =========================================================" | lolcat' >> .bashrc
echo 'echo -e "     *                 Autoscript By JohnFordTV              *" | lolcat' >> .bashrc
echo 'echo -e "     *                   Debian 9 & Debian 10                *" | lolcat' >> .bashrc
echo 'echo -e "     *                   Facebook: johndesu090               *" | lolcat' >> .bashrc
echo 'echo -e "     =========================================================" | lolcat' >> .bashrc
echo 'echo -e "     *    + make sure you setup dns records on cloudflare +   *"' >> .bashrc
echo 'echo -e "     =========================================================" | lolcat' >> .bashrc
echo 'echo -e ""' >> .bashrc

 
 # Showing script's banner message
 ScriptMessage
 sleep 10
 
  # Showing additional information from installating this script
echo " "
echo "The server is 100% installed. Please read the server rules and reboot your VPS!"
echo " "
echo "--------------------------------------------------------------------------------"
echo "*                            Debian Premium Script                             *"
echo "*                                 -JohnFordTV-                                 *"
echo "--------------------------------------------------------------------------------"
echo ""  | tee -a log-install.txt
echo "-------------------"  | tee -a log-install.txt
echo "Server Information "  | tee -a log-install.txt
echo "-------------------"  | tee -a log-install.txt
echo "   - Timezone    : Asia/Manila (GMT +8)"  | tee -a log-install.txt
echo "   - Fail2Ban    : [OFF]"  | tee -a log-install.txt
echo "   - IPtables    : [ON]"  | tee -a log-install.txt
echo "   - Auto-Reboot : [OFF]"  | tee -a log-install.txt
echo "   - IPv6        : [OFF]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "--------------------------------"  | tee -a log-install.txt
echo "Application and Port Information"  | tee -a log-install.txt
echo "--------------------------------"  | tee -a log-install.txt
echo "   - SlowDNS		: 53 "  | tee -a log-install.txt
echo "   - OpenSSH		: Port1: $SSH_Port1 Port2: $SSH_Port2"  | tee -a log-install.txt
echo "   - Dropbear		: Port1: $Dropbear_Port1 Port2: $Dropbear_Port2"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "--------------------"  | tee -a log-install.txt
echo "Important information"  | tee -a log-install.txt
echo "--------------------"  | tee -a log-install.txt
echo "   - Installation Log    : cat /root/log-install.txt"  | tee -a log-install.txt
echo "   - Webmin              : http://$IPADDR:10000/"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "-----------------------"  | tee -a log-install.txt
echo "Premium Script Information"  | tee -a log-install.txt
echo "-----------------------"  | tee -a log-install.txt
echo "Please make sure you setup the dns records to make server work properly"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo " ©JohnFordTV"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "---------------------------- REBOOT YOUR VPS! -----------------------------"

 # Clearing all logs from installation
rm -rf /root/.bash_history && history -c && echo '' > /var/log/syslog

