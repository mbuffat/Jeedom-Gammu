#!/bin/sh
# (C) Marc BUFFAT 2016
# script executer par Gammu lors de la reception d'un SMS
# variables d'environnement
# SMS_1_CLASS='-1'
# SMS_1_NUMBER= numero tel
# SMS_1_TEXT= message
# SMS_MESSAGES='1'  nbre de SMS
# en argument le fichier contenant le SMS
FILE=$1
MESSAGE=$SMS_1_TEXT 
FROM=$SMS_1_NUMBER
LOG="/usr/share/nginx/www/jeedom/log/SMS.log"
PHPDIR="/usr/share/nginx/www/jeedom/plugins/script/core/ressources"
INPUT="/var/spool/gammu/inbox/"
REP=`/usr/bin/php $PHPDIR/JEEDOM_interact.php "$MESSAGE"`
if [ "$REP" != "-1" ]; then
  sudo /usr/bin/gammu-smsd-inject TEXT $FROM -text "$REP" >/var/spool/gammu/LOG
fi
echo `date`" JEEDOM SMS from "$FROM" : "$MESSAGE" file="$FILE" reponse="$REP >> $LOG
rm $INPUT/$FILE
exit 0
