---
layout: ts_fr
title: Installation de Sphinx
---


Installation de Sphinx
----------------------

### MacOS X

Sphinx *est* disponible via les MacPorts - mais celà inclu un gros
avertissement: Vous devez avoir MySQL et/ou PostgreSQL installés via les
MacPorts. Si vous ne l’avez pas, la compilation par les sources est la
meilleure solution. Ses instructions peuvent être trouvés dans la
section UNIX.

Il y a deux problèmes récurrent que les personnes ont détectés. La
première est que iconv et/ou expat XML parser doit être mis à  jour.
Clinton Nixon a [écrit des instructions claire à ce
sujet](http://www.viget.com/extend/installation-sphinx-on-x-leopard) et
comment mettre en place ceci.

L’autre problème apparait seulement quand vous indexez vos données ou
lors du démarrage du service.

{% highlight sh %}  
dyld: Library not loaded: \\  
 /usr/local/mysql/lib/mysql/libmysqlclient.15.dylib  
 Referenced from: /usr/local/bin/indexer  
 Reason: image not found  
{% endhighlight %}

Un patch pour ça est d’ajouter un lien symbolique ayant pour source les
librairies MySQL et en destination ce que Sphinx demande.

{% highlight sh %}  
sudo ln -s /usr/local/mysql/lib /usr/local/mysql/lib/mysql  
{% endhighlight %}

Vous devez recompiler et réinstaller Sphinx une fois que tout ceci est
fait.

### UNIX

Si vous utilisez Gentoo, Sphinx est disponible via `portage`.
Malheureusement, les utilisateurs de Debian et d’Ubuntu n’auront pas
cette chance. et devront le compiler à  partir des sources. Je ne sais
pas ou en est les investigations pour les autres distributions et outils
de gestion de paquets.

Compiler à partir des sources ne devrait pas poser de problèmes.
[Téléchargez la source](http://www.sphinxsearch.com/downloads.html) à
partir du site web Sphinx - la version 0.9.8.1 est la plus récente
version stable pour le moment. Il vous faudra l’installer avec le
support MySQL:

{% highlight sh %}  
./configure  
make  
sudo make install  
{% endhighlight %}

Si vous avez besoin du support PostgreSQL, le chemin des librairies
devra être explicitement mis lors de la configuration.

{% highlight sh %}  
./configure —with-pgsql=/usr/local/include/postgresql  
{% endhighlight %}

Le chemin des librairies peuvent être déterminés en exécutant la
commande suivante

{% highlight sh %}  
pg\_config —pkgincludedir  
{% endhighlight %}

### Windows

Si vous avez installé Sphinx sous Windows, tout ce que vous devez faire
est de récupérer
[l’installeur](http://www.sphinxsearch.com/downloads.html) depuis le
site Sphinx (l’un a le support PostgreSQL et MySQL, l’autre a juste le
MySQL). Installez, et vous êtes prêt.
