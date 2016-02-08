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

