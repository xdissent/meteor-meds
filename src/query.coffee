
meds = Npm.require 'meds'


class Meds.Query extends meds.Query

  Meds.Util.wrapAsyncSuper this::, ['end', 'scores', 'score', 'match']

  skip: (skip) ->
    @_start = skip ? 0
    this

  limit: (limit) ->
    @_stop = if limit? then limit + @_start else 0
    this
