#  Jeedom-Gammu

# Interface Jeedom/Gammu pour la gestion des SMS

## Introduction
Ayant découvert récemment la domotique avec [JEEDOM](https://www.jeedom.com/site/fr/), un logiciel de domotique open-source pouvant s'installer sur un Raspberry avec une communauté dynamique, j'ai voulu sécuriser ma domotique Jeedom sous Raspberry avec un dongle USB GSM pour:

 - l'envoi de notification par SMS sur mon portable a partir de Jeedom
 - d'exécuter des commandes sur ma domotique à partir de SMS  


> Dans JEEDOM, il existe un [plugin SMS](https://www.jeedom.com/doc/documentation/plugins/sms/fr_FR/sms) développé par Loïc et Mathieu, qui est la solution la plus simple pour gérer les SMS sous JEEDOM. Malheureusement le nombre de clé GSMS supporté est limité et la clé que je possède ne fonctionne pas avec le plugin.

> NOUVEAU: sous JEEDOM il existe maintenant un plugin Gammu qui automatise l'installation et l'utilisation de gammu. C'est ce que j'utilise maintenant. Ce qui est décrit ici permet cependant de comprendre le fonctionnement du plugin et d'aider à résoudre éventuellement les problèmes.

- Clé USB UMTS HSDPA UMTS [Huawei E169](http://www.amazon.fr/gp/product/B004DEJEMY?psc=1&redirect=true&ref_=oh_aui_detailpage_o09_s00)

Ayant trouver une solution avec GAMMU, je vous propose donc de la partager sous github

## Prérequis

- un Raspberry Pi sous raspian Jessie (ou une autre distribution Debian/Linux)
- une distribution Jeedom [voir installation ](https://www.jeedom.com/doc/documentation/installation/fr_FR/doc-installation.html)
- installé les packages gammu et gammu_smsd (daemon)   testé avec la version 1.33
```
sudo apt-get update
sudo apt-get -y install gammu gammu-smsd python-gammu
```
[GAMMU](http://fr.wammu.eu/) est le nom du projet et de l'utilitaire en ligne de commande qui vous permet de de contrôler votre téléphone.  [La base de compatibilité Gammu](http://fr.wammu.eu/phones/) avec les téléphones est assez impressionnante et il fonctionne avec la majorité des distributions Linux.

## Configuration de Gammu-smsd
L'objectif est de configurer un daemon Unix qui se charge de recevoir et d'envoyer les SMS.

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
Les points importants de la configuration
 - spécifier le bon port USB dans la variable **port =** pour le dongle GSM. Pour cela taper:
  
```
> sudo gammu_detect
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
En général plusieurs ports ttyUSB sont crées. Dans mon cas j'ai choisi **/dev/ttyUSB2**.
N'oublier pas de spécifier le code PIN de la carte SIM

- Spécifier le script Unix à exécuter lors de la réception d'un SMS dans la variable **RunOnReceive =**
ce script dans **/var/spool/gammu/SMSDreceive.sh** sera détailler plus loin.

- Enfin pour des questions de sécurité, n'autoriser que certains numéros de téléphone à envoyer des SMS à gammu (et donc jeedom) en spécifiant les numéros à la fin (number1, number2, ...)

- **(new)** configuration du daemon gammu-smsd

attention: pour pouvoir utiliser les interactions avec JEEDOM il faut que le daemon gammu-smd soit sous root.

  - dans le script du service gammu **/etc/init.d/gammu-smsd** remplacer **USER=gammu** par **USER=root**

  - avec **visudo** ajouter aussi la ligne
```
gammu ALL=(ALL) NOPASSWD: /usr/bin/gammu-smsd-inject
```

- Lancer le service gammu-smsd
```
sudo service gammu-smsd start
```
Il sera ensuite automatiquement lancé à chaque redémarrage du système

Pour vérifier l'état du daemon, on utilise la commande:
```
sudo service gammu-smsd status
```


Pour tester l'envoi de SMS:
```
sudo gammu-smsd-inject TEXT numero_telephone -text "ceci est un test de SMS"
```
## envoi de SMS 
Pour envoyer un SMS il suffit de créer un fichier script **SMSDsend.sh**, que l'on place dans le répertoire des scripts utilisateurs:
 **/usr/share/nginx/www/jeedom/plugins/script/core/ressources**
```
#! /bin/bash
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
```
Sous Jeedom, on crée ensuite une commande script sendSMS avec une commande 
**send** de type script->action ->message
avec la requête: 
```
/usr/share/nginx/www/jeedom/plugins/script/core/ressources/SMSDsend.sh  #title# "#message#"
```
On alors sur le dashboard Jeedom une commande sendSMS  avec un titre qui correspond au numéro de téléphone et un message contenant le message du SMS à envoyer. On l'inclut ensuite dans les scénarios pour toutes les notifications (alarme, onduleur, ..)

## reception de SMS
lors de la réception de SMS par GAmmu, le daemon exécute le script définit dans le fichier de configuration **/var/spool/gammu/SMSDreceive.sh**
```
#!/bin/sh
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
```
Ce script récupère les informations du SMS et envoie le message à Jeedom en exécution une requête d'interaction à l'aide d'un script php **JEEDOM_interact.php**. En cas de succès, le script envoie la réponse par SMS à l'appelant. A la fin le script efface le SMS du répertoire GAMMU inbox. De même on peut rajouter la purge du répertoire GAMMU **sent** qui contient une copie des SMS envoyés en ajoutant après le if:
```
rm -f /var/spool/gammu/sent/*smsbackup

```

Le script php **JEEDOM_interact.php** est placé dans me répertoire des scripts utilisateurs JEEDOM:
si vous voulez utiliser un mot clé JEEDOM dans le SMs, enlever les commentaires 
à la ligne if (strncmp($argv[1],"JEEDOM ",7)==0 et pour le else
```
<?php
$URL_JEEDOM="http://adresse IP du raspberry/jeedom";
$API_KEY="cle API";
require 'jsonrpcClient.class.php';
// recherche mot cle JEEDOM
// if (strncmp($argv[1],"JEEDOM ",7)==0) {
  $jsonrpc = new jsonrpcClient($URL_JEEDOM.'/core/api/jeeApi.php', $API_KEY);
  $message= substr($argv[1],7);
  if($jsonrpc->sendRequest('interact::tryToReply', array('query'=>$message))){
    print_r($jsonrpc->getResult());
  }else{
    echo $jsonrpc->getError();
  }
//} else {
//   echo "-1";
//}
?>
```
Ce script décode tout d'abord le SMS pour savoir si c'est une commande à envoyer à JEEDOM. Pour cela le texte du SMS doit 
s'écrire:
```
JEEDOM commande_jeedom
```
où **commande_jeedom** est la commande passer à l'interpréteur d'interaction de Jeedom.

Ce script php  utilise la classe jsonrpcClient de Loic Gevrey, dont une version se trouve dans le dépôt git ainsi que tous les fichiers scripts décrits. IL suffit donc de récupérer le dépôt git et de modifier ces fichiers pour les adapter à votre environnement.

## utilisation du plugin GAMMU
@lunarok a écrit un plugin permettant d'automatiser l'utilisation de gammu sous jeedom, que je vous conseille.

## Résolution des problèmes

- le plugin de @lunarok utilise gammu et le daemon gammu-smd pour la gestion des SMS. Il faut donc vérifier dans la base de données 

[http://fr.wammu.eu/phones]   si la clé USB ou le téléphone est bien supporté

- installé ensuite la clé puis le plugin et faire un test en envoyant un SMS avec le plugin. Attention le numéro de téléphone doit être  écrit au format standard : +336xxxxxxx

- en cas de problème ou pour vérifier la configuration, il faut se connecter en ligne de commande par ssh sur la machine JEEDOM

- vérifier que le daemon gammu-smd est actif  avec la commande:
```
sudo service gammu-smsd status
```
La réponse doit contenir un etat active(running)

  gammu-smsd.service - LSB: Gammu SMS daemon
   Loaded: loaded (/etc/init.d/gammu-smsd)
   Active: active (running) since dim. 2016-03-06 11:28:03 CET; 4h 21min ago
 ......

Dans le cas contraire, il faut essayer de redémarrer le service avec
```
sudo service gammu-smsd restart
```

- essayer d'envoyer un SMS directement avec gammu en spécifiant un numéro de téléphone +336xxxx et un message
```
sudo /usr/bin/gammu-smsd-inject TEXT +336xxxx -text "mon message SMS"
```

[*] lancer un outil de monitoring du fonctionnement de gammu
```
 sudo gammu-smsd-monitor
```
qui indique en particulier le niveau du signal, le nombre de SMS envoyés et reçus (sortir en tapant ^C)

- vérifier les permissions: en particulier le daemon gammu-smd tourne sous le compte gammu, et dans les  scripts on fait des sudo.
Il faut donc que l'utilisateur gammu soit dans la base sudo. Pour cela utiliser [b]visudo[/b] et ajouter à la fin la ligne
```
gammu ALL=(ALL) NOPASSWD: /usr/bin/gammu-smsd-inject
```

- regarder dans le répertoire [b]/var/spool/gammu[/b] les sous-répertoires error,  inbox et outbox pour une copie des SMS envoyés ou reçus

- regarder dans les logs, en particulier dans /var/log/syslog les messages de gammu

Le système avec gammu, une fois bien configuré est très robuste et stable et permet une interaction simple avec le plugin JEEDOM pour envoyer ou recevoir des SMS avec le système d' interactions de JEEDOM. Je l'utilise pour envoyer l'état de mon alarme et passer des commandes à JEEDOM, qui par les SMS est plus fiable qu'en 3G.

Je l'utilise avec une Clé USB UMTS HSDPA UMTS Huawei E169 à 30€ connecté en USB sur mon pi2 et une carte FREE à 2€
**Marc BUFFAT  2016**
