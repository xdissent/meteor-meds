
@Bios = new Meteor.Collection 'bios', search: true, autoindex: false

Munit.run
  name: 'TestSuiteBasicSearch'

  suiteSetup: ->
    Bios.insert seed for seed in BiosSeeds
    Bios.index seed._id for seed in BiosSeeds

  testIsSeeded: (test) ->
    test.equal Bios.find({}).count(), 10

  testIsIndexed: (test) ->
    test.equal Bios.indices.find({}).count(), 10

  testLimit: (test) ->
    test.equal Bios.search('acm', limit: 2).count(), 2

  testSkip: (test) ->
    test.equal Bios.search('acm', skip: 2).count(), 3
    test.equal Bios.search('java', skip: 1).count(), 0

  testSkipLimit: (test) ->
    test.equal Bios.search('acm', skip: 2, limit: 2).count(), 2
    test.equal Bios.search('year', skip: 2, limit: 1).count(), 1

  testFindOne: (test) ->
    test.equal Bios.search('year', skip: 2).findOne().awards.length, 3

  testCount: (test) ->
    test.equal Bios.search('acm').count(), 5
    test.equal Bios.search('ieee').count(), 4
    test.equal Bios.search('year').count(), 9

  suiteTearDown: ->
    Bios.remove {}
    Bios.indices.remove()
