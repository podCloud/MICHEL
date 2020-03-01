# M.I.C.H.E.L

Module Indépendant de Calculs Horodatés des Elements Livrés.

## Lexique

- **Feed** : Flux RSS publié
- **Item** : Episode publié dans un flux RSS
- **Enclosure** : Fichier attaché à un Item, téléchargé par les apps de podcasts. 
Il est accédé via une url "proxy" (gateway en réalité) qui s'occupe de noter le téléchargement et de rediriger vers l'adresse original de l'enclosure.
- **Download** : ****Requête GET sur l'enclosure donnant lieu à une sauvegarde de l'évenement dans la base de donnée
- **View** : Requête GET sur le Feed donnant lieu à une sauvegarde de l'évenement dans la base de donnée

## Fonctionnement actuel

Beaucoup de choses sont à jeter, mais je détaille tout de même le fonctionnement actuel :

A chaque requete, on enregistre un event de Download ou de View, et on redirige vers l'enclosure ou affiche le flux RSS. 

Pour chaque requête sur les enclosures, on enregistre les informations du téléchargement de la façon suivante : 

    {
     source: "feed", 
    	// peut être feed, player, download, podcloud 
    	// (choisi selon un paramètre de l'url)
     country: "France", // Pays correspondant à l'IP (GeoIP)
     city: "Toulouse", // Ville correspondant à l'IP (GeoIP)
     ip: "f528764d624db129b32c21fbca0cb8d6", // Hash de l'IP de l'utilisateur (GeoIP)
     user_agent: "iTunes", // User Agent de la requête
     unique_index: "f528764d624db129b32c21fbca0cb8d6_1582815",
    	// Concatenation de l'ip du visiteur et 
    	// du timestamp de sa visite tronqué des 3 derniers caractères
    	//
    	// Permet grace à un index unique de limiter l'enregistrement
    	// des downloads à un seul toutes les 999s
    	// 
     daily_timecode: 1580601600000, // Timestamp en milisecondes du jour du téléchargement à 00:00:00 UTC
     monthly_timecode: 1580515200000, // Timestamp en milisecondes du premier jour du téléchargement à 00:00:00 UTC
     item_id: guid,
     feed_id: guid,
     created_at: Date,
     updated_at: Date
    }

Pour chaque requête sur les feeds, on enregistre les informations de la requête de la façon suivante :

    {
     source: "feed", 
    	// peut être feed, ou site 
    	// (choisi selon une visite du flux rss ou 
    	// du minisite créé pour le podcast)
     country: "France", // Pays correspondant à l'IP (GeoIP)
     city: "Toulouse", // Ville correspondant à l'IP (GeoIP)
     ip: "f528764d624db129b32c21fbca0cb8d6", // Hash de l'IP de l'utilisateur (GeoIP)
     user_agent: "iTunes", // User Agent de la requête
     referer: "https://blabla.com/gfdgfdf",
     referer_host: "blabla.com",
     daily_timecode: 1580601600000, // Timestamp en milisecondes du jour du téléchargement à 00:00:00 UTC
     monthly_timecode: 1580515200000, // Timestamp en milisecondes du premier jour du téléchargement à 00:00:00 UTC
     daily_timecode_with_ip: "1580601600000_f528764d624db129b32c21fbca0cb8d6", // Timestamp en milisecondes du jour du téléchargement à 00:00:00 UTC
     monthly_timecode_with_ip: "1580515200000_f528764d624db129b32c21fbca0cb8d6", // Timestamp en milisecondes du premier jour du téléchargement à 00:00:00 UTC
    	// Concatenation du timestamp (jour ou mois) 
    	// de sa visite et de l'ip du visiteur
    	//
    	// Permet le calcul des visiteurs uniques
    	// 
     feed_id: guid,
     created_at: Date,
     updated_at: Date
    }

**A savoir :** 

- Le champ `source` peut contenir une autre valeur personnalisée, qui n'est plus maintenant utilisée et regroupé sous le label "Autre"
- Les champs `country`, `city` peuvent contenir leurs valeurs dans plusieurs formats selon la date de l'enregistrement (valeur unique, code pays, ou pour les villes tableau de noms dans toutes les langues)
- Les champs `ip`, `*_timecode_with_ip`, contiennent sur les plus vieux enregistrement les IPs en clair.
- Les timecodes sont utilisés pour compiler les données par jours et mois et sont en milisecondes pour être utilisés facilement en JS pour l'affichage. (inutile en fait, mais bon à l'époque j'avais pensé que c'était une bonne idée)
- Le comptage des visites sur le site est voué à être abandonné (tout le monde s'en fout)

Tous les jours sont calculés à partir de ces enregistrements, des DownloadCount et des ViewCount qui eux sont utilisés pour dessiner les courbes. Des sortes de projections.

On regroupe les téléchargements pour chaque feed_id, et item_id, pour chaque source, et on compte leur nombre par daily_timecode, et par monthly_timecode. 

On enregistre alors ce nombre dans un DownloadCount :

    {
      feed_id: guid,
      period_starting_at: Date, // Début du mois ou du jour
      timecode: Int, // Timecode de cette période
      sorting: "daily ou monthly", // Selon si on compte le nombre de downloads groupé par monthly ou daily
      source: "feed", // La source comptée
      count: 45 // Le nombre de downloads concernés
    }

Pour chaque jour, et chaque début de mois on a donc 4 DownloadCount avec chacun une source différente : feed, player, download, podcloud

Ce comptage concerne les téléchargements de tous les items du feed. Un compte **mensuel uniquement** spécifique à chaque item_id est également créé dans des DownloadItemCount :

    {
      feed_id: guid,
      item_id: guid,
      period_starting_at: Date, // Début du mois
      timecode: Int, // Timecode de cette période
    
      rss: 4, // Nombre de DL sur la source "feed" ce mois
      player: 2, // Nombre de DL sur la source "player" ce mois
      download: 7, // Nombre de DL sur la source "download" ce mois
      podcloud: 7, // Nombre de DL sur la source "podcloud" ce mois
      other: 1, // Nombre de DL sur les autres sources ce mois
      total: 21 // Nombre de DL sur toutes les sources
    }

Pour les ViewCount sur le Feed, la compilation des View est quasi identique aux DownloadCount :

    {
      feed_id: guid,
      period_starting_at: Date, // Début du mois ou du jour
      timecode: Int, // Timecode de cette période
      sorting: "daily ou monthly", // Selon si on compte le nombre de downloads groupé par monthly ou daily
      source: "feed", // La source comptée
      count: 45 // Le nombre de downloads concernés
      unique: true // false, selon si on compte en groupant par timecode ou timecode_with_ip
    }

La différence est que le calcul est doublé à chaque fois en prenant d'abord les daily/monthly timecode, puis les `_timecode_with_ip` afin de compter les vues de visiteurs uniques

Pour chaque jour, et chaque début de mois on a donc 4 ViewCount avec chacun une source différente : feed, site, et deux mode unique true et false

Une dernière "projection" est calculée : RefererCount qui permet de savoir les sources depuis lequels ont a des visites sur son flux RSS.

Ils sont calculés par mois, en comptant les referer_host uniques ( autres que le propre ndd du minisite du podcast ).

Ils sont enregistrés comme suit :

    {
      feed_id: guid,
      period_starting_at: Date, // Début du mois ou du jour
      timecode: Int, // Timecode de cette période
      host: "facebook.com", // hostname
      count: 45 // nombre d'occurence
      percentage: 5 // pourcentage par rapport à tous les referers
    }

C'est pour le moment assez foireux : par ex c'est compté comme des referer différent quand c'est facebook.com, facebook.fr, fr.facebook.com, m.facebook.com etc

Deux derniers stats sont calculées à partir des Counts eux même :

- Chaque Feed a une popularitée, calculée depuis plusieurs variables : l'age du Feed, l'age des derniers Item, combien de téléchargements depuis la publication de la dernière Item, etc.
- Chaque Utilisateurs a un récapitulatif sur son dashboard de ses vues, et téléchargements de tous ses Feeds pour les derniers 24h, 7j et 31j.

Certaines de ces compilations de données ne sont pas utilisées, d'autres sont affichés mais tout le monde s'en fout, donc elles sont inutiles. Et beaucoup de projections utiles manquent à l'appel (quels users agent visitent le plus le podcast, quels région/ville/pays ? etc) 

## Quoi garder ? Quoi jeter ?

Globalement, tout est à refaire, on peut imaginer un tout autre système de stockage des évenements, avec un tout autre format. Pour l'instant rien n'est filtré, il faudra dans le nouveau système un filtrage par user agent de certaines visites : aucun intérêt à compter les visites et dl de robots. 

A voir si ce filtrage est a faire coté projection, ou coté event log pour éviter de le saturer. Actuellement la collection views sature assez vite avec des millions de vues car ajoutées dans la durée, car un enregistrement à chaque request. 

La base de données souffre pas mal de ces enregistrements également.

### Événements

Le nouveau système devra s'inspirer et suivre les recommendations [IAB 2.0](https://www.iab.com/wp-content/uploads/2017/12/Podcast_Measurement_v2-Final-Dec2017.pdf) : c'est une certification de système d'audience de podcast. 

Le but n'est pas de le suivre à la perfection, car la certification coute des milliers d'euros, donc elle n'est pas envisagée mais on peut essayer d'y coller le plus possible car elle est loin d'être bête dans son fonctionnement.

Pour respecter l'IAB il faut pouvoir filtrer un maximum les visites robots, en premier lieu. Puis en second lieu enregistrer une seule fois une visite du flux RSS et un téléchargement par utilisateur unique. 

Cet utilisateur unique est determiné par un couple : User Agent + IP sur une période de 24h. Ce couple permet de différiencer avec une marge d'erreur minimale 2 personnes différentes.

Voici les informations à stocker dans les nouveaux évenements.

Les ViewEvent et DownloadEvent ont ces champs en commun :

- Unique ID (couple User Agent / IP passé dans un hash pour garder la confidentialité)
- Feed ID
- User Agent
- Referer
- Pays ( code Pays ISO 3166-1 alpha 3)
- Region
- Ville
- Date de l'événement

Le DownloadEvent a 2 champs supplémentaires : 

- Item ID
- Source (sous forme d'enum : feed (Flux RSS) / download (Bouton Télécharger) / player (mini lecteur) / podcloud ( Écouté via podCloud ) / other (source inconnue)

Note : Les informations de Pays, Region, et Ville sont récupéré via GeoIP au moment de la création de l'évenement pour éviter d'avoir des informations faussée. Par exemple si on reset les projections, les attributions d'IPs auront peut être changé depuis la date de l'évenement. Cela permet aussi d'éviter d'avoir à gérer GeoIP dans MICHEL (ça n'est pas son role)

Les events sont filtrés en amont par Unique ID : pas d'enregistrement de l'event s'il en existe déjà un autre event créé il y a moins de 24h avec cet Unique ID et ce FeedID (et ce ItemID si applicable) 

### Projections

Toutes les projections sont à réimaginer également. Certaines sont à jeter, d'autres à refaire différemment.  

**Vues**

Il faut produire une projection journalière, et mensuelle des abonnés aux Feed. Cela corresponds au compte des View enregistrées par jour pour chaque podcast. Une projection avec un simple incrément de ce compteur fonctionne très bien :

    {
      feed_id,
      type, // monthly or daily
      date, // a minuit utc du jour en cours pour un daily, 
    	// ou du 1er jour du mois pour un monthly
      count // incrémenté à chaque event
    }

La projection incrémente donc deux compteur, le daily du jour et le monthly du mois pour son feed_id.

On jette le principe d'avoir une distinction visites / visiteurs uniques, et d'avoir ce chiffre pour les visites du mini site. On fait des stats de podcast, on veut savoir combien de personnes réelle vérifie le flux rss au moins 1 fois dans la journée, le reste on s'en fout.

**Téléchargements**

Pour les téléchargements, le principe est identique, on rajoute juste le fait de compter cela par item_id plutôt que par feed_id. On garde quand même le feed_id afin d'être capable de pouvoir récupérer tous les stats d'un podcast.

On rajoute également un champ source pour différencier les provenances des téléchargements.

    {
      feed_id,
      item_id,
      type, // monthly or daily
      date, // a minuit utc du jour en cours pour un daily, 
    	// ou du 1er jour du mois pour un monthly
      source, // la source du téléchargement (feed / download / player / podcloud / other)
      count // incrémenté à chaque event
    }

La projection incrémente donc deux compteur, le daily du jour et le monthly du mois pour son item_id + source.

Une nouvelle mini projection associée :

    {
      feed_id,
      item_id,
      item_days_old, // expliqué en dessous
      count // incrémenté à chaque event
    }

La valeur `item_days_old` correspond à la différence de temps en nombre de jour entier entre la date de publication, et la date du compteur. 

L'intérêt de cette valeur est de pouvoir proposer des courbes de l'évolution du nombres de téléchargement au jour de la publication, à j+1, j+2, etc. Et pouvoir comparer les performances des épisodes entre eux.

Étant donné qu'on peut changer la date de publication d'un épisode, il faudra qu'on réfléchisse à ce qu'on fait (on se base sur la première date de publication d'un épisode ? On la stocke quelque part ? Côté legacy ?) 

**Popularité et Dashboard**

Ce sont les deux principales projections car elles correspondent aux vues déjà existantes, donc celles à reproduire avant de penser à en faire d'autres. A l'execution de ces 2 projections devront être déclenché plusieurs side effects.

Pour les téléchargements uniquement (pour le moment), il faut déclencher un side effect qui déclenche la mise à jour d'une valeur (non historisé) de popularité calculée à partir du nombre de téléchargement et de l'âge des derniers épisodes et du podcast.

La valeur sera stockée sous la forme suivante :

    {
      feed_id, 
      popularity
    }

La valeur de popularity correspond à la formule suivante :

![M%20I%20C%20H%20E%20L/6P3VqSm.png](M%20I%20C%20H%20E%20L/6P3VqSm.png)

- δ => temps depuis […]
- Σ => somme de […]/nombre de […]
- Episode 1 => Première publication du flux
- Episode n => dernière publication en date
- Episode n-1 => avant-dernière publication en date
- Episode n-2 => avant-avant-dernière publication en date

Il faudra définir si ces informations seront récupérée directement via la DB legacy (mongodb) ou via l'api graphql (pour éviter d'utiliser le driver Mongo d'elixir qui est relativement peu développé). À voir également si on les stockent dans notre DB à part comme des projections ou si on fait plutôt une mutation graphql pour modifier les valeurs directes dans mongodb. Dans les 2 cas il faudra prévoir la possibilité de moments où la base de donnée serait indisponible (et de facto l'api graphql), cela peut arriver en cas de surcharge. 

Il faut se poser la question de la gravité de "rater" un de ces side effects. Théoriquement s'ils sont déclenché à chaque fois que les comptes de téléchargements sont mis à jour, ça ne devrait pas être "dramatique" de rater une mise à jour de popularité, car la valeur bougera probablement peu.

Pour le dashboard, il faut déclencher la mise à jour d'un hash par utilisateur qui ressemble à ça :

    {
      "day": {
         "downloads": 123,
         "views": 101
      },
      "week": {
         "downloads": 823,
         "views": 630
      }, 
      "month": {
         "downloads": 3423,
         "views": 2001
      },
    }

Ces nombres sont la sommes toutes les valeurs journalières des compteurs de downloads et de view, du jour en cours, des 7 derniers jours, des 30 derniers jours.

A voir également si ces valeurs sont stocké sur MICHEL ou si on les renvoies sur mongodb. 

## Serveur et protocoles

On va dissocier complètement le redirection vers l'enclos ure originale, et l'enregistrement des stats. Actuellement les deux sont fait par le legacy, et l'inconvénient est que si quelque chose plante (la db, tout rails qui freeze si pas de worker puma dispo), l'utilisateur a son téléchargement qui ne se déclenche pas ou qui timeout et crash.

Actuellement le serveur de rendu des flux RSS est un petit projet node qui utilise l'api graphql pour afficher les flux RSS. Et il appelle un api d'un serveur de stats pour enregistrer les vues à la volée (sur le papier, dans les faits cette api de stats est une lib et fait direct les requêtes à la db) 

Le serveur de redirection sera probablement aussi un petit truc en node à côté dans un autre repo qui s'occupe uniquement de faire la 302. Il y aura un cache pour pouvoir redirect rapidement sans avoir de soucis d'accès à la db. Et les appels vers MICHEL pour enregistrer les downloads seront fait en arrière plan.

L'idée est donc que notre serveur de stats propose un api pour envoyer des commandes rajoutant les évents de vues et de download. Par expérience, un simple api http n'est pas possible : c'était ce qui était utilisé dans le premier serveur de stats, et cela a été abandonné dans la même journée de la mise en prod. Le nombre de requêtes est bien trop important et ouvrir et fermer des sockets et des connexions à la db (principale erreur) pour chaque événement est trop coûteux.

Pour limiter les communications inutiles et les ouverture et fermeture d'io, je propose un serveur websocket (à sécuriser) pour l'envoi des commandes : les serveurs de flux et de redirection d'enclosure ouvrirons chacuns un canal de communication vers le serveur de stats et n'auront qu'à envoyer les commandes d'ajout de vues dans le canal déjà ouvert.

Pour la lecture des projections, un simple api http est envisagé.

Jusque là les apis privés ont été protégés via des jwt à chiffrage asynchrone. À voir si on fait ça ou autre chose. 

L'api ne peux pas être public car il permettrait à n'importe qui de rajouter des visites ou obtenir les stats d'un podcast.
