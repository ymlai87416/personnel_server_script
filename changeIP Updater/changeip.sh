#!/bin/bash
############################################################################################
## Author: Eric Ste-Marie
## Email: estemari@sympatico.ca
## Date:  December third 2000
## Note:  This script falls under Gnu General Public Licence.  
##        go to "http://www.gnu.org/copyleft/gpl.html" for more information.
##        basically, it tells you that you have the legal permission to copy, 
##        distribute and/or modify
##        the software. It also tells you that it comes with NO WARRANTY.
##
##
## 03.02.26 Patched for SourceMage GNU/Linux by Mathieu Lubrano <mlubrano@sourcemage.org>
## 
###########################################################################################
##
## Script to update changeIP dynamic dns to include as a  cron job.
## i.e.: "15,45 * * * * /usr/sbin/changeip.sh" to run it every 30 minutes
##
## It uses lynx patched with SSL
##
## PATHTOLYNX= patch to lynx. You can try "which lynx" on the command line 
##             to find out
## PATHTOIFCONFIG = path to the ifconfig command, usually /sbin/ifconfig
## PATHTOCURRENTIP = file where to store the most recent ip
## PATHTOLOGFILE = file where to log information
## INTERFACE = Network interface to configure.  e.g. ppp0, eth0, ppp
##             (you can find out with ifconfig -a)
## USER = Your changeIP username
## PASSWORD = Your changeIP password.  Note that if you want, you could
##            put the password in something like /etc/changeip/secret
##            and set PASSWORD=`cat /etc/changeip/secret`   Don't forget
##            to make this script and that file readable only by root
##            (chmod 700) for obvious reasons.
## CMD = changeIP commmand. update for most of us
## SET = 1
## OFFLINE = 0 (or one to put your domain name to your offline ip.
##
## 
##
## Don't forget to chmod 700 the script as you have the password in there. 
## (chmod 700 /sbin/SCRIPTNAME)
## Don't forget to chown root:root the script or bin:bin . 
## (chown root:root /sbin/SCRIPTNAME)
## 
## After you run the script for the first time, remember to verify that the 
## log files are NOT readable by anybody else than root, especially if you 
## use debug mode (set -x) 

if [ ! -e "/etc/changeip.conf" ]; then
  echo "Error, /etc/changeip.conf file missing."
  exit 1
fi

source /etc/changeip.conf || (echo "Error loading /etc/changeip.conf" ; exit 1)

if [ "$DEBUG" == "on" ]; then
  echo "Debug mode on, look in /var/log/changeip.log and /var/state/changeip.ip..."
  set -x                                    #uncomment to run in debug mode
fi

umask 777                                    #To set file creation to 600
#CURRENTIP=`$PATHTOIFCONFIG -a|grep -A 1 $INTERFACE|grep inet|awk '{print $2}' | awk -F: '{print $2}'`
CURRENTIP=`curl -s http://whatismijnip.nl | cut -d " " -f 5`

grep $CURRENTIP $PATHTOCURRENTIP 1>/dev/null 2>&1

if [ $? -ne 0 ];
then
  $PATHTOLYNX -dump -accept_all_cookies "https://www.changeip.com/update.asp?u=$USER&p=$PASSWORD&cmd=$CMD&set=$SET&offline=$OFFLINE" 1>>$PATHTOLOGFILE 2>&1
  CURRENTIP=`$PATHTOIFCONFIG -a|grep -A 1 $INTERFACE|grep inet|awk '{print $2}' |awk -F: '{print $2}'`
  echo "$CURRENTIP" > $PATHTOCURRENTIP
else
  exit 1
fi

exit 0
