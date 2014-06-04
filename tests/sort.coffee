
Munit.run
  name: 'TestSuiteSearchSort'

  suiteSetup: ->
    Bios.insert seed for seed in BiosSeeds
    Bios.index seed._id for seed in BiosSeeds

  testSort: (test) ->
    bio = Bios.search('acm', sort: birth: 1).fetch()[0]
    test.equal bio._id, '1'
    bio = Bios.search('acm', sort: birth: -1).fetch()[0]
    test.equal bio._id, '7'
    bio = Bios.search('acm', sort: [['birth', 'asc']]).fetch()[0]
    test.equal bio._id, '1'
    bio = Bios.search('acm', sort: [['birth', 'desc']]).fetch()[0]
    test.equal bio._id, '7'

  suiteTearDown: ->
    Bios.remove {}
    Bios.indices.remove()
