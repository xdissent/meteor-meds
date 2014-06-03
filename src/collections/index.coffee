
class Meds.IndexCollection extends Meds.Collection

  constructor: (collection, options = {}) ->
    options.search = false
    options._preventAutopublish = true
    super "meds_index_#{collection._name}", options
    @__collection = collection
    @_meds = collection._meds
    @_fields = options.index ? []
    @_observing = false
    @_observe() if options.autoindex

  _observe: ->
    return if @_observing
    @_observing = true
    options = {}
    if @_fields.length > 0
      options.fields = {}
      options.fields[field] = true for field in @_fields
    initializing = true
    @__collection.find({}, options).observeChanges
      added: (id, doc) => @index id unless initializing
      removed: (id) => @deindex id
      changed: (id, doc) =>
        return @index id if @_fields.length is 0
        return @index id for field of doc when field in @_fields
    initializing = false

  # XXX make fields option behave like mongo query fields option
  _words: (doc) ->
    fields = if @_fields.length > 0 then @_fields else Object.keys doc
    doc[field] for field in fields

  _index: (id, callback) ->
    @_deindex id, (err) =>
      return callback err if err?
      doc = @__collection.findOne _id: id
      return callback new Error 'Failed to retrieve doc for index' unless doc?
      start = new Date
      words = EJSON.stringify @_words doc
      @_meds.index words, id, (err) =>
        return callback err if err?
        @insert _id: id, start: start, stop: new Date, callback

  index: Meteor._wrapAsync @::_index

  _deindex: (id, callback) ->
    @_meds.remove id, (err) =>
      return callback err if err?
      @remove id, callback

  deindex: Meteor._wrapAsync @::_deindex
