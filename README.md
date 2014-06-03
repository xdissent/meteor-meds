meds
====

MongoDB full-text search for Meteor using
[meds](https://github.com/xdissent/meds), a fork of
[reds](https://github.com/visionmedia/reds).


Example
-------

```console
$ git clone https://github.com/xdissent/meteor-meds.git
$ cd meds/example
$ mrt
```


Usage
-----

Add a `search` option when creating a Meteor collection:

```js
Posts = new Meteor.collection('posts', {search: true});
```

Add documents to your collection and index them:

```js
Posts.insert({_id: '1', title: 'frist!', content: 'I am teh winner'});
Posts.index('1');
```

Search!

```js
var post = Posts.search('winner').findOne();
console.log(post.content); // "I am teh winner"
```

The `search` method also accepts `limit` and `skip` options:

```js
var posts = Posts.search('winner', {limit: 3, skip: 1}).fetch();
```


Publishing
----------

To manually publish a cursor for search results on the server:

```js
Meteor.publish('posts-search', function (query) {
  Posts.search(query);
});
```

Subscribe to the cursor on the client:

```js
Deps.autorun(function () {
  Meteor.subscribe('posts-search', Session.get('query'));
});
```


Auto-indexing
-------------

Meds can monitor your collections and automatically index your documents when
they are added/changed/removed. To enable auto-indexing, use the `autoindex`
option:

```js
Posts = new Meteor.collection('posts', {search: true, autoindex: true});
```
