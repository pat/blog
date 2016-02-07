---
layout: ts_fr
title: Indexation
---


Indexation de vos Models
------------------------

Tout ce qui concerne les indexes pour vos models va dans la méthode
**define\_index** à l’intérieur de votre model.

{% highlight ruby %}  
class Article < ActiveRecord::Base
  # ...

  define_index do
    indexes subject, :sortable => true  
 indexes content  
 indexes author(:name), :as =&gt; :author, :sortable =&gt; true

has author\_id, created\_at, updated\_at  
 end

\# …  
end  
{% endhighlight %}

### Les Champs

La méthode **indexes** ajoute un (ou plusieurs) champs, faisant
référence à vos noms de colonne du model.

{% highlight ruby %}  
indexes content  
{% endhighlight %}

Gardez à l’esprit que si vous référencé une colonne qui partage son nom
avec une méthode Ruby (comme par exemple id, name ou type), vous allez
avoir besoin de le spécifier à l’aide d’un symbole.

{% highlight ruby %}  
indexes :name  
{% endhighlight %}

Cependant vous n’avez pas besoin de garder les mêmes noms que dans la
base de données. Utilisez le mot clé **:as** pour signier l’alias.

{% highlight ruby %}  
indexes content, :as =&gt; :post  
{% endhighlight %}

Vous pouvez également définir un champ comme étant triable.

{% highlight ruby %}  
indexes subject, :sortable =&gt; true  
{% endhighlight %}

Si il y a des associations dans votre model, vous pouvez acceder aux
autres colonnes. Un alias est *obligatoirement* requis quand on veux
faire ça.

{% highlight ruby %}  
indexes author(:name), :as =&gt; :author  
indexes author.location, :as =&gt; :author\_location  
{% endhighlight %}

### Les Attributs

La méthode **has** ajoute un (ou plusieurs) attributs, et tout comme la
méthode **indexes**, celà nécessite le bon accord des noms de colonne du
model.

{% highlight ruby %}  
has author\_id  
{% endhighlight %}

La syntaxe est très proche de la configuration des champs. Vous pouvez
définir des alias, acceder aux associations. Cependant vous n’avez pas
besoin de définir un attribut comme étant **:sortable** - dans Sphinx,
tous les attributs peuvent être utilisés comme étant triable.

{% highlight ruby %}  
has tags(:id), :as =&gt; :tag\_ids  
{% endhighlight %}

### Traitement des indexes

Une fois que vous avez configurés vos indexes comme vous le vouliez,
vous pouvez lancer [la tâche rake](rake_tasks.html) pour dire à Sphinx
de traiter les données.

{% highlight sh %}  
rake thinking\_sphinx:index  
{% endhighlight %}

Lorsque le model sera traité, vous verrez un message du type ci-dessous.
C’est juste un avertissement, pas une erreur. Tout ira bien.

{% highlight sh %}  
distributed index ‘article’ can not be directly indexed; skipping.  
{% endhighlight %}

Cependant, si vous faite une modification de structure à votre index (ce
qui veux dire tout sauf l’ajout de données dans les tables de la base de
données), vous aurez alors besoin d’arreter Sphinx, réindexer, et de le
redémarrer.

{% highlight sh %}  
rake thinking\_sphinx:stop  
rake thinking\_sphinx:index  
rake thinking\_sphinx:start  
{% endhighlight %}
