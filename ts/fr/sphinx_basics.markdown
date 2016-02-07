---
layout: ts_fr
title: Les bases de Sphinx
---


Introduction à Sphinx
---------------------

### Qu’est ce que Sphinx?

Sphinx est un moteur de recherche. Vous lui donnez vos documents, et
chacun d’entres eux aura un identifiant unique et son texte associé,
vous pourrez ensuite lui envoyer vos différents critères de recherche,
et il vous dira quel document est le plus pertinant suivant ses
critères. Si vous êtes habitué à Lucene, Ferret ou Solr, c’est très
similaire. Vous avez le service qui est en fonctionnement, vos données
indexées, et puis en utilisant le client en quelque sorte vous commencez
la recherche.

Quand vous indexez vos données, Sphinx est en relation directe avec
votre source de données - qui doit être soit MySQL, PostgreSQL, ou des
fichiers XML - ce qui veux dire que l’indexation peut être très rapide
(Si vos requêtes SQL ne sont pas trop complexes).

### Fonctionnement de Sphinx

Le service Sphinx (le processus connu sous le nom de searchd) interagi
avec une collection d’indexes. Chaque index intègre une série de
documents, et chaque document est constitué de champs et d’attributs.
Tandis que dans d’autres logiciel vous pouvez utiliser ses deux critères
de manière indifférente, ils ont des sens *différent* dans Sphinx.

### Les Champs

Les champs sont le contenu pour vos critères de recherches - donc, si
vous voulez des mots liés à un document spécifique, il serait préférable
qu’il soit en tant que champ dans votre index. Il y a seulement des
données au format chaîne - vous pourrez avoir des nombres et des dates,
etc.. dans vos champs, mais Sphinx les traitera en tant que chaîne, rien
d’autre.

### Les Attributs

Les attributs sont utilisés pour le tri, le filtrage et le groupement de
vos résultats de recherche. Ces valeurs ne sont d’aucunes utilités pour
Sphinx dans ses critères de recherche, cependant, et ils sont limités
aux types de données suivantes: entiers, flottants, datetimes
(timestamps Unix - et donc de toute façon des entiers), les booléens, et
les chaînes. Prenez note que les attributs de chaîne de caractères sont
converties en entiers ordinal, ce qui est particulièrement utile pour le
tri, mais pas à grand chose d’autre.

### Attributs à valeurs multiples

Sphinx supporte également des tableaux d’attributs pour un même document
- ce qui est nommé attributs à valeurs multiples. Actuellement, seuls
les entiers sont supportés, ce qui n’est pas aussi souple que les
attributs normaux, mais il est important de le préciser.
