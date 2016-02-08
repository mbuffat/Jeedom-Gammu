#  Jeedom-Gammu

# interface Jeedom/Gammu pour la gestion des SMS

## Introduction
Ayant découvert récemment la domotique avec [JEEDOM](https://www.jeedom.com/site/fr/), un logiciel de domotique open-source pouvant s'installer sur un Raspberry avec une communauté dynamique, j'ai voulu sécuriser ma domotique Jeedom sous Raspberry avec un dongle USB GSM pour:

 - l'envoi de notification par SMS sur mon portable a partir de Jeedom
 - d'exécuter des commandes sur ma domotique à partir de SMS  


> Dans JEEDOM, il existe un [plugin SMS](https://www.jeedom.com/doc/documentation/plugins/sms/fr_FR/sms) développé par Loïc et Mathieu, qui est la solution la plus simple pour gérer les SMS sous JEEDOM. Malheureusement le nombre de clé GSMS supporté est limité et la clé que je possède ne fonctionne pas avec le plugin.

- Clé USB UMTS HSDPA UMTS Huawei E169 [voir ici p.e.](http://www.amazon.fr/gp/product/B004DEJEMY?psc=1&redirect=true&ref_=oh_aui_detailpage_o09_s00)

Ayant trouver une solution avec GAMMU, je vous propose donc de la partager sous github

## Prérequis

- un Raspberry Pi sous raspian Jessie (ou une autre distribution Debian/Linux)
- installé les packages gammu et gammu_smsd (daemon)   testé avec la version 1.33
```
sudo apt-get update
sudo apt-get -y install gammu gammu-smsd python-gammu
```
[GAMMU](http://fr.wammu.eu/) est le nom du projet et de l'utilitaire en ligne de commande qui vous permet de de contrôler votre téléphone.  [La base de compatibilité Gammu](http://fr.wammu.eu/phones/) avec les téléphones est assez impressionante et il fonctionne sous la majorité des distributions Linux.

## Configuration de Gammu-smsd
L'objectif est d'avoir un daemon Unix qui se charge de recevoir et d'envoyer les SMS.

La première chose à faire est de créer un fichier de configuration **/etc/gammu-smdrc** en s'inspirant du fichier ci-dessous.

```
# Gammu library configuration, see gammurc(5)
[gammu]
# Please configure this!
port = /dev/ttyUSB2
connection = at
GammuLoc = fr_FR.UTF8
gammucoding = utf8
#LogFormat = nothing
# SMSD configuration, see gammu-smsdrc(5)
[smsd]
logfile = syslog
# Increase for debugging information
debuglevel = 0
RunOnReceive = /var/spool/gammu/SMSDreceive.sh
pin = 1234
#service = null
# Paths where messages are stored
service = files
inboxpath = /var/spool/gammu/inbox/
outboxpath = /var/spool/gammu/outbox/
sentsmspath = /var/spool/gammu/sent/
errorsmspath = /var/spool/gammu/error/
[include_numbers]
number1 = +33xxxxxxxx
number2 = +33xxxxxxxx
```
Les points importants:
 - spécifier le bon port USB dans la variable **port =** pour le dongle GSM. Pour cela taper:
  
 **gammu_detect**
```
; Fichier de configuration généré par gammu-detect.
; Please check The Gammu Manual for more information.

[gammu]
device = /dev/ttyUSB0
name = Téléphone sur le port USB série HUAWEI_Mobile
connection = at

[gammu1]
device = /dev/ttyUSB1
name = Téléphone sur le port USB série HUAWEI_Mobile
connection = at

[gammu2]
device = /dev/ttyUSB2
name = Téléphone sur le port USB série HUAWEI_Mobile
connection = at

[gammu3]
device = /dev/ttyACM0
name = Arduino_Srl Arduino_Uno
connection = at
```
En général plusieurs ports ttyUSB sont crées. Dans mon cas j'ai choisi /dev/ttyUSB2.
N'oublier pas de spécifier le code PIN de la carte SMS (free dans mon cas)

- Spécifier le script Unix a executer lors de la reception d'un SMS dans la variable **RunOnReceive = **
ce script dans **/var/spool/gammu/SMSDreceive.sh** sera détailler plus loin.

- Enfin pour des questions de sécurité, n'autoriser que certains numéros de téléphone à envoyer des SMS à gammu (et donc jeedom) en spécifiant les numéros à la fin (number1, number2, ...)

## envoi de SMS 

## reception de SMS
