---
---

class Search
  constructor: ->
    @uri        = new URI window.location.href
    @page       = parseInt(@uri.search(true).page || 1)
    @results    = $('#results')
    @pagination = $('.pagination')
    @previous   = $('.pagination .previous')
    @next       = $('.pagination .next')
    @drumknott  = new Drumknott 'pat'

    @next.on     'click', @nextPage
    @previous.on 'click', @previousPage

    $('#query').val(@uri.search(true).query);

    @pagination.hide()
    @previous.hide()
    @next.hide()

  run: ->
    @results.empty().html('<li class="loading">Loading...</li>');
    @pagination.hide();

    console.log "Searching for #{$('#query').val()} (page #{@page})"

    @drumknott.search
      query: $('#query').val(),
      page:  @page
    , @display

  display: (data) =>
    @results.empty();

    console.log data

    for result in data.results
      $('#results').append("<li class=\"result\"><a href=\"#{result.path}\">#{result.name}</a></li>");

    @toggleElement @pagination, data.pages > 1
    @toggleElement @previous,   data.page  > 1
    @toggleElement @next,       data.page < data.pages

  nextPage: =>
    @page++;
    @updateState()
    @run()

    return false

  previousPage: =>
    @page--;
    @updateState()
    @run()

    return false

  toggleElement: (element, visible) ->
    if visible
      element.show()
    else
      element.hide()

  updateState: =>
    @uri.setSearch page: @page.toString(), query: $('#query').val()

    history.pushState @uri.search(true), '', @uri.path() + @uri.search()

search = new Search

$('#search').on 'submit', ->
  search.page = 1
  search.updateState()
  search.run()

  return false

search.run() if $('#query').val().length > 0
