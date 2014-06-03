
class Meds.Collection extends Meteor.Collection

  constructor: (name, options = {}) ->
    super
    return unless options.search
    @_meds = new Meds.Collection "meds_search_#{name}", search: false
    
  search: (query, options = {}) ->
    return unless @_meds?
    options.sort ?= [['_meds_score', 'desc']]
    options.fields ?= _meds_score: false, _meds_query: false
    @_meds.find _meds_query: query, options
