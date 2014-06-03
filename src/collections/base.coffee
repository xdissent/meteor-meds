
class Meds.Collection extends Meteor.Collection

  constructor: (name, options = {}) ->
    super
    return unless options?.search
    @_meds = new Meds.Search @_name
    @searches = new Meds.SearchCollection this, options
    @indices = new Meds.IndexCollection this, options

  search: (query, options) ->
    return unless @_meds?
    @searches.search query, options

  index: (id, callback) ->
    return unless @_meds?
    @indices.index arguments...

  reindex: (id, callback) ->
    return unless @_meds?
    @indices.index arguments...

  deindex: (id, callback) ->
    return unless @_meds?
    @indices.deindex arguments...
