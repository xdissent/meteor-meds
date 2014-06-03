
Munit.run
  name: 'TestSuiteSearchCursorRemove'

  suiteSetup: ->
    Bios.insert seed for seed in BiosSeeds
    Bios.index seed._id for seed in BiosSeeds

  testRemoveBelow: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: 'ieee'
    Bios.index 'xxx'
    Bios.search('ieee')._publishCursor sub
    test.length sub.docs(), 5
    Bios.remove _id: 'xxx'
    Bios.deindex 'xxx'
    sub.wait 'removed'
    sub.stop()
    test.length sub.docs(), 4
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())

  testRemoveBelowHitLimit: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: 'ieee'
    Bios.index 'xxx'
    Bios.search('ieee', limit: 2)._publishCursor sub
    test.length sub.docs(), 2
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())
    Bios.remove _id: 'xxx'
    Bios.deindex 'xxx'
    test.isTrue sub.waitFail 'removed'
    sub.stop()
    test.length sub.docs(), 2
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())

  testRemoveInRange: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: 'acm'
    Bios.index 'xxx'
    Bios.search('acm')._publishCursor sub
    test.length sub.docs(), 6
    Bios.remove _id: 'xxx'
    Bios.deindex 'xxx'
    sub.wait 'removed'
    sub.stop()
    test.length sub.docs(), 5
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())

  testRemoveInRangeHitLimit: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: ['ieee', 'ieee']
    Bios.index 'xxx'
    Bios.search('ieee', limit: 3)._publishCursor sub
    test.length sub.docs(), 3
    Bios.remove _id: 'xxx'
    Bios.deindex 'xxx'
    sub.wait 'added' # Wait for replacement result
    sub.stop()
    test.length sub.docs(), 3
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())
    test.equal sub.docs()[2]._meds_score, 1

  testRemoveAbove: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: ['ieee', 'ieee', 'ieee']
    Bios.index 'xxx'
    Bios.search('ieee')._publishCursor sub
    test.length sub.docs(), 5
    test.equal sub.docs()[0]._id, 'xxx'
    Bios.remove _id: 'xxx'
    Bios.deindex 'xxx'
    sub.wait 'removed'
    sub.stop()
    test.length sub.docs(), 4
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())

  testRemoveAboveHitLimit: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: ['ieee', 'ieee', 'ieee']
    Bios.index 'xxx'
    Bios.search('ieee', limit: 3)._publishCursor sub
    test.length sub.docs(), 3
    test.equal sub.docs()[0]._id, 'xxx'
    Bios.remove _id: 'xxx'
    Bios.deindex 'xxx'
    sub.wait 'added'
    sub.stop()
    test.length sub.docs(), 3
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())

  testRemoveAboveSkip: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: ['ieee', 'ieee', 'ieee']
    Bios.index 'xxx'
    Bios.search('ieee', skip: 2)._publishCursor sub
    test.length sub.docs(), 3
    test.length (true for doc in sub.docs() when doc._meds_score is 1), 2
    test.equal sub.docs()[0]._meds_score, 2
    Bios.remove _id: 'xxx'
    Bios.deindex 'xxx'
    sub.wait 'removed'
    sub.stop()
    test.length sub.docs(), 2
    test.equal sub.docs()[0]._meds_score, 1
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())

  testRemoveAboveSkipLimit: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: ['ieee', 'ieee', 'ieee']
    Bios.index 'xxx'
    Bios.search('ieee', skip: 1, limit: 2)._publishCursor sub
    test.length sub.docs(), 2
    test.equal sub.docs()[0]._meds_score, 2
    test.equal sub.docs()[1]._meds_score, 2
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())
    Bios.remove _id: 'xxx'
    Bios.deindex 'xxx'
    sub.wait 'added'
    sub.stop()
    test.length sub.docs(), 2
    test.equal sub.docs()[0]._meds_score, 2
    test.equal sub.docs()[1]._meds_score, 1

  suiteTearDown: ->
    Bios.remove {}
    Bios.indices.remove()
