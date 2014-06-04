meds
====

[![Build Status](https://travis-ci.org/xdissent/meteor-meds.svg)](https://travis-ci.org/xdissent/meteor-meds)

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
Posts = new Meteor.Collection('posts', {search: true});
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

The `search` method also accepts `limit`, `skip`, `sort` and `fields` options:

```js
var posts = Posts.search('winner', {
  limit: 3,
  skip: 1,
  sort: [['published', 'desc']],
  fields: {title: true, author: true, published: true}
}).fetch();
```


Publishing
----------

To manually publish a cursor for search results on the server:

```js
Meteor.publish('posts-search', function (query) {
  return Posts.search(query); // Adding a `limit` option is recommended.
});
```

Subscribe to the cursor on the client:

```js
Deps.autorun(function () {
  Meteor.subscribe('posts-search', Session.get('query'));
});

Template.search.results = function () {
  return Posts.search(Session.get('query'));
};
```


Auto-indexing
-------------

Meds can monitor your collections and automatically index your documents when
they are added/changed/removed. To enable auto-indexing, use the `autoindex`
option:

```js
Posts = new Meteor.Collection('posts', {search: true, autoindex: true});
```


Indexed Fields
--------------

By default, all document fields are indexed (except `_id`, which is *never* 
indexed). To change this behaviour, pass a valid mongo
[field specifier](https://docs.meteor.com/#fieldspecifiers) as the `index`
option when creating a collection:

```js
// Index only the `title` and `content` fields:
Posts = new Meteor.Collection('posts', {search: true, index: {title: true, content: true}});

// Index all fields except the `comments` field:
Posts = new Meteor.Collection('posts', {search: true, index: {comments: false}});
```
