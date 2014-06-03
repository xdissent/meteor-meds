
@Bios = new Meteor.Collection 'bios', search: true, autoindex: true


if Meteor.isServer
  
  Meteor.publish 'bios-search', (search) -> Bios.search search, limit: 3

  Meteor.methods
    seed: -> Bios.insert seed for seed in BiosSeeds
    clear: -> Bios.remove {}

else

  Deps.autorun -> Meteor.subscribe 'bios-search', Session.get 'search'

  Template.search.helpers
    results: -> Bios.search Session.get 'search'

    lifespan: -> "(#{@birth.getFullYear()}-#{@death?.getFullYear?() ? ''})"

    json: (val) -> JSON.stringify val

  Template.search.events
    'click #search': (evt) -> Session.set 'search', $('#query').val().trim()
    'click #seed': (evt) -> Meteor.call 'seed'
    'click #clear': (evt) -> Meteor.call 'clear'
