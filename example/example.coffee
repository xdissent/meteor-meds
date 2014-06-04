
@Bios = new Meteor.Collection 'bios', search: true, autoindex: true

if Meteor.isServer
  
  Meteor.publish 'bios-search', (query) -> Bios.search query

  Meteor.methods
    seed: -> Bios.insert seed for seed in BiosSeeds
    clear: -> Bios.remove {}

else

  Deps.autorun -> Meteor.subscribe 'bios-search', Session.get 'query'

  Template.search.helpers
    results: -> Bios.search Session.get 'query'
    query: -> Session.get 'query'

  Template.search.events
    'click #search': (evt) -> Session.set 'query', $('#query').val().trim()
    'click #seed': (evt) -> Meteor.call 'seed'
    'click #clear': (evt) -> Meteor.call 'clear'
