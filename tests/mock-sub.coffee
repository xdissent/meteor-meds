
class @MockSub
  constructor: -> @_docs = {}
  onStop: (fn) -> @_stop = fn
  added: (name, id, doc) -> @_docs[id] = doc
  changed: (name, id, fields) -> @_docs[id][f] = v for f, v of fields
  removed: (name, id) -> delete @_docs[id]
  stop: -> @_stop?()
  docs: -> (doc for id, doc of @_docs).sort (a, b) ->
    return 0 if a._meds_score is b._meds_score
    if a._meds_score < b._meds_score then 1 else -1

  __wait: (evt, time = 1000, count = 1, callback) ->
    unless @_spied?
      @_spied = new Date
      sinon.spy this, evt
    if @[evt].callCount is count
      @[evt].restore()
      @_spied = null
      return callback()
    return callback new Error 'Timed out' if new Date - @_spied > time
    Meteor.setTimeout =>
      @__wait evt, time, count, callback
    , 100

  _wait: Meteor._wrapAsync @::__wait

  wait: (evt, time = 2000, count = 1, callback) ->
    @_wait evt, time, count, callback

  waitFail: (evt, time = 500, count = 1) ->
    try
      @wait evt, time, count
    catch err
      return true
    false
