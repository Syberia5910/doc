# Nos premières ressources

Dans le monde Kubernetes, _**TOUT est ressource**_ : un déploiement est une ressource, un pod est une ressource, une configuration est une ressource, un disque est une ressource, etc. Tous ces objets Kubernetes peuvent être décrits dans un fichier (souvent un fichier yaml).

Le ```Pod``` est la ressource minimale  et triviale (éphémère, stateless et recréable) qu’il est possible de déployer dans Kubernetes en termes de ressources applicatives. Pour faire simple, un pod est une ressource qui héberge un ou plusieurs containers. Comme pour un conteneur démarré avec Docker, vous devez définir une image Docker à consommer, des variables, des volumes. Par exemple :

```
oc run mynginx --image registry.takima.io/school/proxy/nginx
```

Pour chaque ressource, la seule source fiable reste la documentation officielle de Kubernetes (ou de l'api).

Pour le Pod, c'est par ici : [https://kubernetes.io/docs/concepts/workloads/pods/](https://kubernetes.io/docs/concepts/workloads/pods/)

Je vous propose donc de créer votre première ressource ! Connectez vous à votre cluster préféré et créer votre premier pod. Pour cela vous aurez uniquement besoin d'une image sur un repo et d'un nom. Nous vous proposons d'utiliser registry-app.hp.csh-dijon.ramage/busybox:latest et un nom original, par exemple busybox

Url des clusters :

Observez la création du pod :

```
oc get pods busybox
```

🤔 ❓ Quelles sont les propriétés principales que l'on retrouve ?

Vous retrouvez dans les root properties :

- apiVersion
- kind
- metadata
- spec


Maintenant, détruisez le pod :

```
oc delete pods busybox
```

## Les définitions en YAML

Nous allons imaginer une application vide, qui s'appelle Unicorn. Pour l'instant, Unicorn n'est qu'un conteneur Nginx tout vide, c'est un front.

Par soucis de convention, nous te proposons de créer un fichier ```unicorn-front-pod.yml```

 ✏️ *Note :*
___Comme dans kubernetes TOUT est ressource yaml, nous te conseillons de créer un dossier et une arborescence pour pouvoir les éditer et les modifier. par exemple TP-kube-01/step-1 dans lequel vous placerez vos ressources yaml manipulées.___

Pour appliquer une ressource kubernetes décrite en tant que yaml la commande est toujours la même : ```oc apply -f monfichier.yml```


À vous de jouer. Essayez de créer la même ressource avec un fichier yaml :

💡 **Tips !**
__Pour avoir le yaml correspondant à une ressource à créer, vous pouvez utiliser la fonction dry-run ! Exemple :__

``` 
oc run mynginx2 --image registry.takima.io/school/proxy/nginx --dry-run=client -o yaml > unicorn-front-pod.yml
```

Cette commande ne créera pas le pod dans kubernetes mais dumpera l'équivalant du fichier yaml qui aurait été envoyé au KubeApi pour la création. C'est très utile pour avoir un template de ressource voulu et ne pas démarrer avec un yaml vierge

NB: Il y a églament une commande ```oc create``` permettant pour créer d'autres ressources supportant le ```--dry-run=client -o yaml``` permettant de générer rapidement les yaml de nos ressources si besoin.

Comme avec docker, dans kubernetes, vous pouvez accéder à votre conteneur en mode exécution si besoin (remarquez que l’on retrouve des options Docker) :

```
kubectl exec nom_du_pod -it -- bash

# -it pour s'attacher de façon interactive et avoir la main dans l'invite de commande
# -i pour attacher stdin et -t pour faire de stdin un TTY
```

Pensez à sortir de votre container avec un ```ctrl + D``` ou ```exit```.

La commande suivante permet de voir les logs :

```
kubectl logs nom_du_pod
```

💡 **Tips !**

Avec l'option ```-f --follow``` le CLI vous stream les logs sur votre terminal.

```
kubectl logs -f nom_du_pod
```

Détruisez maintenant votre pod.

## Impératif vs Déclaratif

Vous venez de voir plusieurs façons de créer une ressource kubernetes :

- kubectl run / kubectl create ...
- kubectl apply -f my-ressources.yaml

Ces deux façons sont bien différentes :

- La première est impérative : elle exécute ce qu'on lui demande
- La seconde est déclarative : elle s'intéresse à l'état que l'on souhaite avoir et réalise les changements/créations nécessaires


De manière générale, on préférera la méthode déclarative pour plusieurs raisons :


1. Lorsque l'on déploie des ressources, c'est l'état qui nous intéresse, et seuls les changements qui nous séparent de l'état voulu doivent être appliqués.
2. La méthode déclarative s'appuie sur du yaml, permettant ainsi à l'état de nos ressources d'être décrit et conservé dans des fichiers (on verra plus tard que c'est très intéressant).
3. C'est bien plus riche, tout n'est pas faisable en impératif.

Pour comprendre une autre différence entre impératif et déclaratif, déployez un pod :

```
kubectl run mynginx --image registry.takima.io/school/proxy/nginx
```

Maintenant, relancez la même commande :

```
kubectl run mynginx --image registry.takima.io/school/proxy/nginx
```

🤔 ❓ **Que se passe-t-il lors de cette deuxième création en impératif ?**


Réalisez la même création avec la méthode déclarative :

```
kubectl run mynginx --image registry.takima.io/school/proxy/nginx --dry-run=client -o yaml > mynginx.yml

kubectl apply -f mynginx.yml
```

🤔 ❓ **Que se passe-t-il lors de cette deuxième création en déclaratif ?**

ℹ️ De la même manière que pour la création de ressources en déclaratif à l'aide d'un fichier yaml, vous pouvez détruire les ressources à partir du même fichier yaml. Par exemple dans le cas précédent ```kubectl delete -f mynginx.yml``` Vous pouvez aussi regrouper plusieurs ressources dans un même yaml pour décrire une stack complète à créer ou détruire.


## Replicaset


Ok, c’est bien : vous avez réussi à déployer un conteneur dans un Pod ! Mais qu'en est-il de la haute disponibilité ou de la scalabilité promise ?

Pour scaler un applicatif, il faut tout simplement rajouter des Pods du même applicatif. Vous pourriez créer à la main plusieurs Pods avec la même image, mais cela ne serait pas très pratique. Il est beaucoup plus efficace de les regrouper au sein d’un groupe de ressources. C’est dans cet objectif que Kubernetes définit les ReplicaSet permettant de contrôler plusieurs pods d’un même applicatif (même image Docker) partageant les mêmes configs, les mêmes propriétés.

Voici un exemple de ressource ReplicaSet:

```
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: unicorn-front-replicaset
  labels:
    app: unicorn-front
spec:
  template:
    metadata:
      name: unicorn-front-pod
      labels:
        app: unicorn-front
    spec:
      containers:
      - name: unicorn-front
        image: registry.takima.io/school/proxy/nginx
  replicas: 3
  selector:
    matchLabels:
      app: unicorn-front
```