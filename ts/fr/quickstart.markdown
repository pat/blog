---
layout: ts_fr
title: Guide de la première utilisation
---


Un guide de la première utilisation afin de configurer Thinking Sphinx.
-----------------------------------------------------------------------

Premièrement, vous allez devoir installer
[Sphinx](installing_sphinx.html) et [Thinking
Sphinx](installing_thinking_sphinx.html). Pendant que Sphinx est en
train de compier, aller lire [quelle est la différence entre les champs
et les attributs](sphinx_basics.html) pour Sphinx. C’est une partie
importante.

Une fois que c’est fait, il est temps de configurer un index sur votre
model. Dans l’exemple ci-dessous, nous prenons l’exemple d’un model
ayant la classe Article.

{% highlight ruby %}  
class Article < ActiveRecord::Base
  # ...

  define_index do
    # fields
    indexes subject, :sortable => true  
 indexes content  
 indexes author.name, :as =&gt; :author, :sortable =&gt; true

\# attributes  
 has author\_id, created\_at, updated\_at  
 end

\# …  
end  
{% endhighlight %}

La prochaine étape est d’indexer vos données:

{% highlight sh %}  
rake thinking\_sphinx:index  
{% endhighlight %}

Si vous voyez un invertissement comme ce qui suit - il ne faut pas en
tenir compte, c’est juste que Sphinx est peu permissif.

{% highlight sh %}  
distributed index ‘article’ can not be directly indexed; skipping.  
{% endhighlight %}

Une fois cette étape effectuée, nous démarrons Sphinx et nous pourrons
envoyer nos requêtes:

{% highlight sh %}  
rake thinking\_sphinx:start  
{% endhighlight %}

Et maintenant nous pouvons chercher!

{% highlight ruby %}  
Article.search “topical issue”  
Article.search “something”, :order =&gt; :created\_at,  
 :sort\_mode =&gt; :desc  
Article.search “everything”, :with =&gt; {:author\_id =&gt; 5}  
Article.search :conditions =&gt; {:subject =&gt; “Sphinx”}  
{% endhighlight %}

Bien sûr, c’est une vue d’ensemble *extrèmement* simple. Il vous sera
très certainement utile d’en lire un peu plus pour une meilleure
compréhension des meilleurs moyens [d’indexation](indexing.html) et de
[recherche](searching.html).
