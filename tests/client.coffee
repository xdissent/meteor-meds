
if Meteor.isServer

  running = false
  seeded = false

  Meteor.publish 'bios-search', (query) -> Bios.search query
  Meteor.methods
    seed: ->
      return unless running
      Bios.remove {}
      Bios.indices.remove()
      Bios.insert seed for seed in BiosSeeds
      Bios.index seed._id for seed in BiosSeeds
      seeded = true
    clear: ->
      Bios.remove {}
      Bios.indices.remove()
      seeded = false

  Munit.run
    name: 'TestSuiteSearchClient'
    timeout: 10000

    suiteSetup: -> running = true

    tests: [
      name: 'testWaitForClientSetup'
      timeout: 10000
      func: (test, done) ->
        done = done ->
        interval = Meteor.setInterval ->
          return unless seeded
          Meteor.clearInterval interval
          done()
        , 10
    ,
      name: 'testWaitForClientTeardown'
      func: (test, done) ->
        done = done ->
        interval = Meteor.setInterval ->
          return if seeded
          Meteor.clearInterval interval
          done()
        , 10
    ]

    suiteTearDown: -> running = false

else

  Munit.run
    name: 'TestSuiteSearchClient'
    timeout: 10000

    suiteSetup: (test, done) ->
      done = done (err) -> throw err if err?
      callback = (err, seeded) ->
        return done err if err?
        return done() if seeded
        Meteor.setTimeout ->
          Meteor.call 'seed', callback
        , 100
      Meteor.call 'seed', callback

    tests: [
      name: 'testClientSearch'
      timeout: 10000
      func: (test, done) ->
        sub = Meteor.subscribe 'bios-search', 'acm', done ->
          test.equal Bios.search('acm').count(), 5
          test.equal Bios.search('acm', limit: 3).count(), 3
          test.equal Bios.search('acm', skip: 2).count(), 3
          test.equal Bios.search('acm', skip: 1, limit: 2).count(), 2
          bio = Bios.search('acm', limit: 1, sort: birth: 1).fetch()[0]
          test.equal bio._id, '1'
          bio = Bios.search('acm', limit: 1, sort: birth: -1).fetch()[0]
          test.equal bio._id, '7'
          bio = Bios.search('acm', limit: 1, sort: [['birth', 'asc']]).fetch()[0]
          test.equal bio._id, '1'
          bio = Bios.search('acm', limit: 1, sort: [['birth', 'desc']]).fetch()[0]
          test.equal bio._id, '7'
          bio = Bios.search('acm').fetch()[0]
          test.isUndefined bio._meds_score
          test.isUndefined bio._meds_query
          bio = Bios.search('acm', fields: _meds_query: true).fetch()[0]
          test.equal bio._meds_query, 'acm'
          bio = Bios.search('acm', fields: _meds_score: true).fetch()[0]
          test.isTrue typeof bio._meds_score is 'number'
          test.isTrue bio._meds_score > 0
          sub.stop()
    ]

    suiteTearDown: (test, done) ->
      Meteor.call 'clear', done (err) -> throw err if err?
