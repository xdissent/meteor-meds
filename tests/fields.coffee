
Munit.run
  name: 'TestSuiteSearchFields'

  suiteSetup: ->
    Bios.insert seed for seed in BiosSeeds
    Bios.index seed._id for seed in BiosSeeds

  testFields: (test) ->
    bio = Bios.search('acm').fetch()[0]
    test.isNotNull bio.name
    bio = Bios.search('acm', fields: name: false).fetch()[0]
    test.isUndefined bio.name
    bio = Bios.search('acm', fields: birth: true).fetch()[0]
    test.isUndefined bio.name

  suiteTearDown: ->
    Bios.remove {}
    Bios.indices.remove()
