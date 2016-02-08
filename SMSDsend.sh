#! /bin/bash
# (C) Marc BUFFAT 2016
# envoie de SMS avec GAMMU: 2 arguments telephone et message
if [ "$#" -eq 2 ]; then
 PHONE=$1
 MESSAGE=$2
else
 PHONE=xxxxxx
 MESSAGE="SMS de test"
fi;
#
sudo gammu-smsd-inject TEXT $PHONE -text "$MESSAGE"
