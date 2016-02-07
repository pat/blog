---
layout: ts_fr
title: Installation de Thinking Sphinx
---


Installation de Thinking Sphinx
-------------------------------

Il y a plusieurs moyens pour installer Thinking dans vos applications
web. Si vous utilisez Rails, lisez la première partie. Si vous utilisez
Merb, gem est le meilleur moyen d’y arriver - faites défiler la page un
peu vers le bas pour y trouver les instructions.

### Rails 2.1 ou supérieur et Git

Si vous avez `git` d’installé, et que vous utilisez Rails 2.1 ou
supérieur, il n’y aura pas de problème pour installer Thinking Sphinx
dans votre application Rails:

{% highlight sh %}  
script/plugin install \\  
 git://github.com/pat/thinking-sphinx.git  
{% endhighlight %}

### Rails 2.0 ou plus ancien et Git

Si vous avez `git`, mais que vous utilisez une version plus ancienne de
Rails, ça devient un peu plus compliqué.

{% highlight sh %}  
git clone \\  
 git://github.com/pat/thinking-sphinx.git \\  
 vendor/plugins/thinking\_sphinx  
{% endhighlight %}

Et si vous voulez être sûr que tout ce qui sera commité soit partie
intégrante de votre principal dépôt, n’oubliez pas de supprimer le
répertoire .git du greffon.

{% highlight sh %}  
rm -r vendor/plugins/thinking\_sphinx/.git  
{% endhighlight %}

### Sans Git

Si vous n’avez pas `git` d’installé, tout n’est pas perdu. Vous pouvez
soit télécharger manuellement le fichier tar.gz à partir de GitHub, et
ensuite l’extraire dans votre répertoire `vendor/plugins`, ou vous
pouvez executer les commandes shell suivante à la racine de votre
application Rails, qui reviendra à faire exactement la même chose.

{% highlight sh %}  
curl -L \\  
 http://github.com/pat/thinking-sphinx/tarball/master \\  
 -o thinking-sphinx.tar.gz  
tar -xvf thinking-sphinx.tar.gz -C vendor/plugins  
mv vendor/plugins/freelancing-god-thinking-sphinx\* \\  
 vendor/plugins/thinking-sphinx  
rm thinking-sphinx.tar.gz  
{% endhighlight %}

### En tant que Gem

Il y a plusieurs étapes pour utiliser Thinking en tant que gem.
Premièrement, l’installation à partir de GemCutter:

{% highlight sh %}  
gem install thinking-sphinx  
{% endhighlight %}

Si vous utilisez Merb, vous avez juste besoin d’inclure la librairie
dans votre `init.rb`:

{% highlight ruby %}  
require ‘thinking\_sphinx’  
{% endhighlight %}

Pour les utilisateurs de Rails, vous aurez besoin d’ajouter la gem à
votre configuration à travers `environnement.rb`

{% highlight ruby %}  
config.gem(  
 ‘thinking-sphinx’, :version =&gt; ‘1.4.4’  
)  
{% endhighlight %}

Et pour finir, une dernière chose: assurez vous que les tâches rake sont
disponibles en ajoutant la ligne suivante dans votre `Rakefile`:

{% highlight ruby %}  
require ‘thinking\_sphinx/tasks’  
{% endhighlight %}
