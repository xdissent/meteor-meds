
Munit.run
  name: 'TestSuiteSearchCursorAdd'

  suiteSetup: ->
    Bios.insert seed for seed in BiosSeeds
    Bios.index seed._id for seed in BiosSeeds

  testInitialResults: (test) ->
    sub = new MockSub
    Bios.search('acm')._publishCursor sub
    test.length sub.docs(), 5
    sub.stop()

  testAddBelow: (test) ->
    sub = new MockSub
    Bios.search('ieee')._publishCursor sub
    test.length sub.docs(), 4
    Bios.insert _id: 'xxx', a: 'ieee'
    Bios.index 'xxx'
    sub.wait 'added'
    sub.stop()
    test.length sub.docs(), 5
    test.isTrue 'xxx' in (doc._id for doc in sub.docs())
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testAddBelowHitLimit: (test) ->
    sub = new MockSub
    Bios.search('ieee', limit: 4)._publishCursor sub
    test.length sub.docs(), 4
    Bios.insert _id: 'xxx', a: 'ieee'
    Bios.index 'xxx'
    test.isTrue sub.waitFail 'added'
    sub.stop()
    test.length sub.docs(), 4
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testAddInRange: (test) ->
    sub = new MockSub
    Bios.search('acm')._publishCursor sub
    test.length sub.docs(), 5
    Bios.insert _id: 'xxx', a: 'acm'
    Bios.index 'xxx'
    sub.wait 'added'
    sub.stop()
    test.length sub.docs(), 6
    test.isTrue 'xxx' in (doc._id for doc in sub.docs())
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testAddInRangeHitLimit: (test) ->
    sub = new MockSub
    Bios.search('ieee', limit: 3)._publishCursor sub
    test.length sub.docs(), 3
    Bios.insert _id: 'xxx', a: ['ieee', 'ieee']
    Bios.index 'xxx'
    sub.wait 'added'
    sub.stop()
    test.length sub.docs(), 3
    test.equal sub.docs()[2]._id, 'xxx'
    test.length (true for doc in sub.docs() when doc._meds_score >= 2), 3
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testAddAbove: (test) ->
    sub = new MockSub
    Bios.search('ieee')._publishCursor sub
    test.length sub.docs(), 4
    Bios.insert _id: 'xxx', a: ['ieee', 'ieee', 'ieee']
    Bios.index 'xxx'
    sub.wait 'added'
    sub.stop()
    test.length sub.docs(), 5
    test.equal sub.docs()[0]._id, 'xxx'
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testAddAboveHitLimit: (test) ->
    sub = new MockSub
    Bios.search('ieee', limit: 3)._publishCursor sub
    test.length sub.docs(), 3
    Bios.insert _id: 'xxx', a: ['ieee', 'ieee', 'ieee']
    Bios.index 'xxx'
    sub.wait 'added'
    sub.stop()
    test.length sub.docs(), 3
    test.equal sub.docs()[0]._id, 'xxx'
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testAddAboveSkip: (test) ->
    sub = new MockSub
    Bios.search('ieee', skip: 2)._publishCursor sub
    test.length sub.docs(), 2
    test.length (true for doc in sub.docs() when doc._meds_score is 1), 2
    Bios.insert _id: 'xxx', a: ['ieee', 'ieee', 'ieee']
    Bios.index 'xxx'
    sub.wait 'added'
    sub.stop()
    test.length sub.docs(), 3
    test.equal sub.docs()[0]._meds_score, 2
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testAddAboveSkipLimit: (test) ->
    sub = new MockSub
    Bios.search('ieee', skip: 1, limit: 2)._publishCursor sub
    test.length sub.docs(), 2
    test.equal sub.docs()[0]._meds_score, 2
    test.equal sub.docs()[1]._meds_score, 1
    Bios.insert _id: 'xxx', a: ['ieee', 'ieee', 'ieee']
    Bios.index 'xxx'
    sub.wait 'added'
    sub.stop()
    test.length sub.docs(), 2
    test.equal sub.docs()[0]._meds_score, 2
    test.equal sub.docs()[1]._meds_score, 2
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  suiteTearDown: ->
    Bios.remove {}
    Bios.indices.remove()
