
class Meds.IndexCollection extends Meds.Collection

  constructor: (collection, options = {}) ->
    options.search = false
    options._preventAutopublish = true
    super "meds_index_#{collection._name}", options
    @__collection = collection
    @_meds = collection._meds
    @_checkFields options.index
    @_observing = false
    @_observe() if options.autoindex

  _checkFields: (fields) ->
    @_fields = fields ? {}
    @_field_names = []
    unless typeof @_fields is 'object'
      throw new Error 'Index option must be a mongo field specifier'
    return unless Object.keys(@_fields).length > 0
    inc = (field for field, inc of @_fields when inc and field isnt '_id')
    exc = (field for field, inc of @_fields when not inc and field isnt '_id')
    @_negate = exc.length > 0
    if inc.length > 0 and @_negate
      throw new Error 'Index option must be a valid mongo field specifier'
    @_field_names = if @_negate then exc else inc

  _indexedField: (field) ->
    return false if field is '_id'
    return true if @_field_names.length is 0
    if @_negate then field not in @_field_names else field in @_field_names

  _observe: ->
    return if @_observing
    @_observing = true
    options = if @_field_names.length > 0 then fields: @_fields else {}
    initializing = true
    @__collection.find({}, options).observeChanges
      added: (id, doc) => @index id unless initializing
      removed: (id) => @deindex id
      changed: (id, doc) =>
        return @index id for field of doc when @_indexedField field
    initializing = false

  _words: (doc) ->
    doc[field] for field of doc when @_indexedField field

  _index: (id, callback) ->
    @_meds.remove id, (err) =>
      return callback err if err?
      doc = @__collection.findOne _id: id
      return callback new Error 'Failed to retrieve doc for index' unless doc?
      start = new Date
      words = EJSON.stringify @_words doc
      @_meds.index words, id, (err) =>
        return callback err if err?
        @upsert id, $set: start: start, stop: new Date, callback

  index: Meteor._wrapAsync @::_index

  _deindex: (id, callback) ->
    @_meds.remove id, (err) =>
      return callback err if err?
      @remove id, callback

  deindex: Meteor._wrapAsync @::_deindex
