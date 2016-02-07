---
layout: ts_fr
title: Contribuer à Thinking Sphinx
---


Contribuer à Thinking Sphinx
----------------------------

-   [Les forks et les patches](#forking)
-   [Les dépendances](#dependencies)
-   [Les spécifications](#specs)
-   [Les tests fonctionnels Cucumber](#cucumber)
-   [Ecriture de gems](#gems)

<h3 id="forking">
Forking and Patching</h3>

Si vous voulez envoyer un patch à Thinking Sphinx, le meilleur moyen
pour le faire est de forker [Le projet
GitHub](http://github.com/pat/thinking-sphinx), de le patcher, et de
m’envoyer une demande de Pull. La dernière étape est importante - même
si je suis peut être votre fork sur GitHub, la demande m’enverra un mail
dans ma boite, et donc, je n’oublierai pas vos modifications.

N’oubliez pas d’ajouter les specifications - et fonctionnalités. Si il y
a une fonctionnalité qui change. Cela permet de garder Thinking Sphinx
aussi stable que possible, et me permet d’y intégrer plus facile vos
modifications.

Quelques fois j’accepte les patches, d’autre fois non. S’il vous plait,
ne soyez pas offensé si votre patche concernant la seconde catégorie -
Je veux garder Thinking Sphinx le plus petit possible, ce qui veux dire
que je n’ajouterai pas toute les fonctionnalités que les personnes me
demandent ou écrivent.

<h3 id="dependencies">
Les dépendences</h3>

Les spécifications de Thinking Sphinx ont été écrites avec RSpec, et les
tests d’intégration avec Cucumber, donc, il vous faudra ses deux gems
d’installés pour commencer. Vous pourrez avoir besoin d’installer YARD,
RedCloth et BlueCloth pour la documentation, et Jeweler pour la gestion
des gems et ses tâches rakes précieuses.

{% highlight sh %}  
gem install rspec cucumber bluecloth RedCloth yard  
{% endhighlight %}

<h3 id="specs">
Les spécifications</h3>

Les spécifications pour Thinking Sphinx nécessite une connexion à la
base de données - et actuellement nous n’interrogeons que la base de
données `thinking_sphinx`. Le nom d’hôte par defaut est `localhost`,
l’utilisateur `thinking_sphinx`, sans mot de passe. Si vous voulez
customiser ses paramètres, créez un fichier YAML nommé
`spec/fixtures/database.yml`. Vous pouvez trouver un exemple de fichier
dans `spec/fixtures/database.yml.default`.

{% highlight yaml %}  
host: localhost  
username: root  
password: secret  
{% endhighlight %}

Dépendant de la version de Sphinx installé, vous pouvez avoir besoin
d’intégrer les spécifications avec la variable d’environnement
`VERSION`. Un exemple ci-dessous:

{% highlight sh %}  
rake spec VERSION=0.9.9  
{% endhighlight %}

<h3 id="cucumber">
Les tests fonctionnels Cucumber</h3>

Les tests fonctionnels Cucumber pour Thinking Sphinx nécessite une base
de donnée et le daemon Sphinx sur le port 9312. Tout ceci est manageable
via `features/support/database.yml` (avec un exemple de fichier
`features/support/database.example.yml`).

Et enfin, comme avec les spécifications, vous devrez lancer les tests
fonctionnels avec la version spécifiée:

{% highlight sh %}  
rake features:mysql VERSION=0.9.9  
{% endhighlight %}

Il y a des tâches fonctionnelles pour `mysql` et `postgresql`, et la
tâche de base se lance pour les deux, l’une après l’autre. Vous devez
avoir la même authentification sur chaque base de données si vous
configurez les tests fonctionnels sur les deux.

<h3 id="gems">
Ecriture de gems</h3>

Si vous écrivez des gems qui se greffe dans Thinking Sphinx, je vous
recommande fortement d’écrire des spécifications qui n’interagisse pas
avec Sphinx ni avec la base de données si c’est possible (via mocks et
stubs). et d’utiliser Cucumber pour les tests d’intégration pour
interargir avec Sphinx.

Pour le moment, Thinking Sphinx fournie une classe Cucumber pour faire
les choses sans prise de tête. Premièrement, votre
`features/support/env.rb` devrait ressembler à ce qui suis:

{% highlight ruby %}  
require ‘rubygems’  
require ‘cucumber’  
require ‘spec/expectations’  
require ‘fileutils’  
require ‘active\_record’

$:.unshift File.dirname(*FILE*) + ‘/../../lib’

require ‘cucumber/thinking\_sphinx/internal\_world’

world = Cucumber::ThinkingSphinx::InternalWorld.new  
world.configure\_database

SphinxVersion = ENV\[‘VERSION’\] || ‘0.9.8’

require “thinking\_sphinx/\#{SphinxVersion}”  
require ‘path/to/thinking\_sphinx/extension’

world.setup  
{% endhighlight %}

Cette classe a pour finaliter quatre choses:

-   Migration de base de données dans in
    `features/support/db/migrations`
-   Les models dans `features/support/models`
-   Ruby fixtures (pour configurer un model en instance) in
    `features/support/db/fixtures`
-   Configuration de la base de données dans
    `features/support/database.yml`

La configuration de la base de données par defaut est:

-   Adapter: `mysql`
-   Host: `localhost`
-   Database: `thinking_sphinx`
-   Username: `thinking_sphinx`

Vous pouvez customiser toute la configuration via des accesseurs sur
l’instance d’InternalWorld dans le fichier `env.rb`.

Je vous recommande de jeter un coup d’oeil sur [la librairie Delta
Asynchrone](http://github.com/pat/ts-delayed-delta/) pour vous inspirer.
