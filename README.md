#  Jeedom-Gammu

# interface gammu avec Jeedom pour la gestion des SMS

## Introduction
Ayant découvert récemment la domotique avec [JEEDOM](https://www.jeedom.com/site/fr/), un logiciel de domotique open-source pouvant s'installer sur un Raspberry avec une communauté dynamique, j'ai voulu sécuriser ma domotique Jeedom sous Raspberry avec un dongle USB GSM pour:

 - l'envoi de notification par SMS sur mon portable a partir de Jeedom
 - d'exécuter des commandes sur ma domotique à partir de SMS  


> Dans JEEDOM, il existe un [plugin SMS](https://www.jeedom.com/doc/documentation/plugins/sms/fr_FR/sms) développé par Loïc et Mathieu, qui est la solution la plus simple pour gérer les SMS sous JEEDOM. Malheureusement le nombre de clé GSMS supporté est limité et la clé que je possède ne fonctionne pas avec le plugin.

- Clé USB UMTS HSDPA UMTS Huawei E169 [voir ici p.e.](http://www.amazon.fr/gp/product/B004DEJEMY?psc=1&redirect=true&ref_=oh_aui_detailpage_o09_s00)

Ayant trouver une solution avec GAMMU, je vous propose donc de 

.Mise à jour : puisque vous êtes équipé d’un Raspberry Pi et d’un dongle GSM, la solution la plus simple est d’utiliser la solution JEEDOM (+ plugin SMS) développée par les deux petits frenchies Loïc et Mathieu.
