require 'jekyll'
require 'json'
require 'faraday'

task :tags do
  site = Jekyll::Site.new Jekyll.configuration
  site.process

  categories = site.categories.keys.sort
  pages      = categories.length / 20
  pages     += 1 if categories.length % 20 > 0

  (1..pages).each do |page|
    file = File.open "categories/#{page}.html", 'w'
    file.puts <<-YAML
---
layout: category_index
title: Categories
section: posts
offset: #{(page - 1) * 20 }
limit: 20
total_pages: #{pages}
page: #{page}
#{ "previous: /categories/#{page - 1}.html" if page > 1 }
#{ "next: /categories/#{page + 1}.html" if page < pages }
categories:
  - #{categories[((page - 1) * 20)...(page * 20)].join("\n  - ")}
---
    YAML
  end

  site.categories.each do |category, posts|
    slug = category.gsub(' ', '-')
    FileUtils.mkdir_p "categories/#{slug}"
    pages  = posts.length / 20
    pages += 1 if posts.length % 20 > 0

    (1..pages).each do |page|
      file = File.open "categories/#{slug}/#{page}.html", 'w'
      file.puts <<-YAML
---
layout: categories
title: "#{category}"
category: "#{category}"
section: posts
slug: #{slug}
offset: #{(page - 1) * 20 }
limit: 20
total_pages: #{pages}
page: #{page}
#{ "previous: /categories/#{slug}/#{page - 1}.html" if page > 1 }
#{ "next: /categories/#{slug}/#{page + 1}.html" if page < pages }
#{ "redirect_from: \"/tags/#{category.gsub(' ', '%20')}/\"" if page == 1 }
---
      YAML
    end
  end
end
