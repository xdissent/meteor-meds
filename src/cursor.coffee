  
class Meds.Cursor

  constructor: (@search_collection, query, @options = {}) ->
    @name = @search_collection._name
    @collection = @search_collection.__collection
    @search = @collection._meds
    @query = @search.query query?.trim?()
    @_resetQuery()
    @_sorter = new Minimongo.Sorter @options.sort ? []
    @rewind()

  rewind: ->
    @_scores = {}
    @_resetStats()
    @_fetched = false

  fetch: ->
    throw new Error 'Already fetched (try rewinding)' if @_fetched
    @_fetched = true
    @_fetch arguments...

  map: (fn) -> @fetch().map fn

  forEach: (fn) -> @fetch().forEach fn

  count: ->
    if @_fetched then @_ids.length else @fetch().length

  findOne: ->
    @query.limit 1
    one = @_fetch(arguments...)?[0]
    @_resetQuery()
    one

  _resetQuery: ->
    @query.type @options.type ? 'and'
      .skip @options.skip ? 0
      .limit @options.limit ? 0
      .exclude null
      .include null
      .min null
      .max null
      .sort -1

  _sort: (docs) ->
    comparator = @_sorter.getComparator()
    docs.sort (a, b) =>
      return comparator a, b if @_scores[a._id] is @_scores[b._id]
      if @_scores[a._id] < @_scores[b._id] then 1 else -1

  _fetch: ->
    @_scores = @query.scores()
    @_resetStats()
    selector = _id: $in: @_ids
    options = fields: @options.fields ? {}
    @_sort (doc for doc in @collection.find(selector, options).fetch())

  _publishCursor: (sub) ->
    return unless @query?.str?.length > 2
    
    @_sub = sub
    @_sub.added @name, doc._id, @_bless doc for doc in @_fetch()
    
    @_initializing = true
    handle = @collection.indices.find().observeChanges
      added: @_added
      removed: @_removed
    @_initializing = false
    @_sub.onStop =>
      handle.stop()
      @_sub = null

  _resetStats: ->
    @_max = 0
    @_min = Infinity
    @_max_id = null
    @_min_id = null
    @_ids = []
    for id, score of @_scores
      @_max = Math.max @_max, score
      @_max_id = id if @_max is score
      @_min = Math.min @_min, score
      @_min_id = id if @_min is score
    @_ids = Object.keys @_scores

  _bless: (doc) ->
    doc._meds_query = @query.str
    doc._meds_score = @_scores[doc._id]
    doc

  _sync: ->
    [scores, ids] = [@_scores, @_ids]
    @_scores = @query.scores()
    @_resetStats()
    added = (id for id in @_ids when id not in ids)
    removed = (id for id in ids when id not in @_ids)
    changed = (id for id in @_ids when id in ids and
      scores[id] isnt @_scores[id])
    @_sub.removed @name, id for id in removed
    for id in changed
      @_sub.changed @name, id, _meds_score: @_scores[id]
    for doc in @collection.find(_id: $in: added).fetch()
      @_sub.added @name, doc._id, @_bless doc

  _hitLimit: -> @_hasLimit() and @_ids.length >= @options.limit

  _hasSkip: -> @options.skip > 0

  _hasLimit: -> @options.limit > 0

  _add: (id, score) ->
    @_scores[id] = score
    @_resetStats()
    @_sub.added @name, id, @_bless @collection.findOne _id: id

  _pop: ->
    delete @_scores[@_min_id]
    @_sub.removed @name, @_min_id

  _shift: ->
    delete @_scores[@_max_id]
    @_sub.removed @name, @_max_id

  _tail: ->
    ex = (id for id in @_ids when @_scores[id] is @_min)
    scores = @query.skip(0).limit(1).exclude(ex).max(@_min).scores()
    @_resetQuery()
    ids = Object.keys scores
    return unless ids.length > 0
    id: ids[0], score: scores[ids[0]]

  _head: ->
    ex = (id for id in @_ids when @_scores[id] is @_max)
    scores = @query.sort(1).skip(0).limit(1).exclude(ex).min(@_max).scores()
    @_resetQuery()
    ids = Object.keys scores
    return unless ids.length > 0
    id: ids[0], score: scores[ids[0]]

  _addedBelow: (id, score) ->
    return if @_hitLimit()
    @_add id, score

  _addedInRange: (id, score) ->
    @_pop() if @_hitLimit()
    @_add id, score

  _addedAbove: (id, score) ->
    return @_add id, score unless @_hasSkip() or @_hitLimit()
    if @_hasSkip()
      head = @_head()
      return unless head?
      [id, score] = [head.id, head.score]
    @_pop() if @_hitLimit()
    @_add id, score

  _added: (id) =>
    return if @_initializing
    score = @query.score id
    return unless score > 0
    return @_addedBelow id, score if score <= @_min
    return @_addedInRange id, score if score <= @_max
    @_addedAbove id, score

  _removedInSet: (id) ->
    delete @_scores[id]
    @_sub.removed @name, id
    return @_resetStats() unless @_hitLimit()
    tail = @_tail()
    return unless tail?
    @_add tail.id, tail.score

  _removed: (id) =>
    return if @_ids.length is 0
    return @_removedInSet id if id in @_ids
    # If not in set and there's no skip, limit must be hit and it's below min
    return unless @_hasSkip()
    # If limit is hit, it's either above or below so just sync
    return @_sync() if @_hitLimit()
    # If limit is not hit, it's def above max, so shift head
    @_shift()
    @_resetStats()
