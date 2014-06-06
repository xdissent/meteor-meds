
Munit.run
  name: 'TestSuiteSearchCursorChangeNotInSet'

  suiteSetup: ->
    Bios.insert seed for seed in BiosSeeds
    Bios.index seed._id for seed in BiosSeeds

  testAddBelow: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: 'xxx'
    Bios.index 'xxx'
    Bios.search('ieee')._publishCursor sub
    test.length sub.docs(), 4
    Bios.update 'xxx', $set: a: 'ieee'
    Bios.index 'xxx'
    sub.wait 'added'
    sub.stop()
    test.length sub.docs(), 5
    test.isTrue 'xxx' in (doc._id for doc in sub.docs())
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testAddBelowHitLimit: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: 'xxx'
    Bios.index 'xxx'
    Bios.search('ieee', limit: 4)._publishCursor sub
    test.length sub.docs(), 4
    Bios.update 'xxx', $set: a: 'ieee'
    Bios.index 'xxx'
    test.isTrue sub.waitFail 'added'
    sub.stop()
    test.length sub.docs(), 4
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testAddInRange: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: 'xxx'
    Bios.index 'xxx'
    Bios.search('acm')._publishCursor sub
    test.length sub.docs(), 5
    Bios.update 'xxx', $set: a: 'acm'
    Bios.index 'xxx'
    sub.wait 'added'
    sub.stop()
    test.length sub.docs(), 6
    test.isTrue 'xxx' in (doc._id for doc in sub.docs())
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testAddInRangeHitLimit: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: 'xxx'
    Bios.index 'xxx'
    Bios.search('ieee', limit: 3)._publishCursor sub
    test.length sub.docs(), 3
    Bios.update 'xxx', $set: a: ['ieee', 'ieee']
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
    Bios.insert _id: 'xxx', a: 'xxx'
    Bios.index 'xxx'
    Bios.search('ieee')._publishCursor sub
    test.length sub.docs(), 4
    Bios.update 'xxx', $set: a: ['ieee', 'ieee', 'ieee']
    Bios.index 'xxx'
    sub.wait 'added'
    sub.stop()
    test.length sub.docs(), 5
    test.equal sub.docs()[0]._id, 'xxx'
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testAddAboveHitLimit: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: 'xxx'
    Bios.index 'xxx'
    Bios.search('ieee', limit: 3)._publishCursor sub
    test.length sub.docs(), 3
    Bios.update 'xxx', $set: a: ['ieee', 'ieee', 'ieee']
    Bios.index 'xxx'
    sub.wait 'added'
    sub.stop()
    test.length sub.docs(), 3
    test.equal sub.docs()[0]._id, 'xxx'
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testAddAboveSkip: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: 'xxx'
    Bios.index 'xxx'
    Bios.search('ieee', skip: 2)._publishCursor sub
    test.length sub.docs(), 2
    test.length (true for doc in sub.docs() when doc._meds_score is 1), 2
    Bios.update 'xxx', $set: a: ['ieee', 'ieee', 'ieee']
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
    Bios.insert _id: 'xxx', a: 'xxx'
    Bios.index 'xxx'
    Bios.search('ieee', skip: 1, limit: 2)._publishCursor sub
    test.length sub.docs(), 2
    test.equal sub.docs()[0]._meds_score, 2
    test.equal sub.docs()[1]._meds_score, 1
    Bios.update 'xxx', $set: a: ['ieee', 'ieee', 'ieee']
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

Munit.run
  name: 'TestSuiteSearchCursorChangeInSet'

  setup: ->
    Bios.insert _id: 'aaa', a: 'xxx'
    Bios.insert _id: 'bbb', a: ['xxx', 'xxx']
    Bios.insert _id: 'ccc', a: ['xxx', 'xxx', 'xxx']
    Bios.index 'aaa'
    Bios.index 'bbb'
    Bios.index 'ccc'

  testRemoved: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: 'xxx'
    Bios.index 'xxx'
    Bios.search('xxx')._publishCursor sub
    test.length sub.docs(), 4
    Bios.update 'xxx', $set: a: 'zzz'
    Bios.index 'xxx'
    sub.wait 'removed'
    sub.stop()
    test.length sub.docs(), 3
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testBelow: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: ['xxx', 'xxx']
    Bios.index 'xxx'
    Bios.search('xxx')._publishCursor sub
    test.length sub.docs(), 4
    Bios.update 'xxx', $set: a: 'xxx'
    Bios.index 'xxx'
    sub.wait 'changed'
    sub.stop()
    test.length sub.docs(), 4
    test.isTrue 'xxx' in (doc._id for doc in sub.docs())
    bio = doc for doc in sub.docs() when doc._id is 'xxx'
    test.equal bio._meds_score, 1
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testBelowHitLimit: (test) ->
    sub = new MockSub
    Bios.update 'aaa', $set: a: ['xxx', 'xxx']
    Bios.index 'aaa'
    Bios.insert _id: 'xxx', a: ['xxx', 'xxx']
    Bios.index 'xxx'
    Bios.search('xxx', limit: 3)._publishCursor sub
    test.length sub.docs(), 3
    test.isTrue 'xxx' in (doc._id for doc in sub.docs())
    Bios.update 'xxx', $set: a: 'xxx'
    Bios.index 'xxx'
    sub.wait 'removed'
    sub.stop()
    test.length sub.docs(), 3
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testAbove: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: ['xxx', 'xxx']
    Bios.index 'xxx'
    Bios.search('xxx')._publishCursor sub
    test.length sub.docs(), 4
    test.isTrue 'xxx' in (doc._id for doc in sub.docs())
    Bios.update 'xxx', $set: a: ['xxx', 'xxx', 'xxx', 'xxx']
    Bios.index 'xxx'
    sub.wait 'changed'
    sub.stop()
    test.length sub.docs(), 4
    test.isTrue 'xxx' in (doc._id for doc in sub.docs())
    test.equal sub.docs()[0]._id, 'xxx'
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  testAboveSkip: (test) ->
    sub = new MockSub
    Bios.insert _id: 'xxx', a: 'xxx'
    Bios.index 'xxx'
    Bios.search('xxx', skip: 2)._publishCursor sub
    test.length sub.docs(), 2
    test.isTrue 'xxx' in (doc._id for doc in sub.docs())
    Bios.update 'xxx', $set: a: ['xxx', 'xxx', 'xxx', 'xxx']
    Bios.index 'xxx'
    sub.wait 'added'
    sub.stop()
    test.length sub.docs(), 2
    test.isFalse 'xxx' in (doc._id for doc in sub.docs())
    Bios.deindex 'xxx'
    Bios.remove _id: 'xxx'

  tearDown: ->
    Bios.deindex 'aaa'
    Bios.deindex 'bbb'
    Bios.deindex 'ccc'
    Bios.remove 'aaa'
    Bios.remove 'bbb'
    Bios.remove 'ccc'
