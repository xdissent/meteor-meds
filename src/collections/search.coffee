
class Meds.SearchCollection extends Meds.Collection

  constructor: (collection, options = {}) ->
    options.search = false
    options._preventAutopublish = true
    super "meds_search_#{collection._name}", options
    @__collection = collection

  search: (query, options = {}) -> new Meds.Cursor this, query, options
