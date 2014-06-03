
meds = Npm.require 'meds'


class Meds.Search extends meds.Search

  Meds.Util.wrapAsyncSuper this::, ['index', 'remove', 'close']

  constructor: (name, args...) -> super "meds_search_#{name}", args...
  
  query: (query) -> new Meds.Query query, this
