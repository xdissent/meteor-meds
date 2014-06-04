
class Meds.Collection extends Meteor.Collection

  constructor: (name, options = {}) ->
    super
    return unless options.search
    @_meds = new Meds.Collection "meds_search_#{name}", search: false
    
  search: (query, options = {}) ->
    return unless @_meds?
    throw new Error 'Invalid options' unless typeof options is 'object'
    options.sort = @_searchSort options.sort
    options.fields = @_searchFields options.fields
    @_meds.find _meds_query: query, options

  _searchSort: (sort = []) ->
    throw new Error 'Invalid sort specifier' unless typeof sort is 'object'
    unless '[object Array]' is {}.toString.call sort
      sort = ([field, @_searchSortDir dir] for field, dir of sort)
    sort.unshift ['_meds_score', 'desc']
    sort

  _searchSortDir: (val) ->
    switch val
      when 'asc', 1 then 'asc'
      when 'desc', -1 then 'desc'

  _searchFields: (fields = {}) ->
    if (f for f, v of fields when v and f isnt '_id').length is 0
      fields._meds_score = false
      fields._meds_query = false
    fields
