Package.describe({
  summary: "MongoDB full-text search for Meteor"
});

Npm.depends({meds: '0.2.7'});

Package.on_use(function (api, where) {
  api.use('coffeescript');
  api.use('minimongo', ['server']);
  api.add_files('src/index.coffee', ['client', 'server']);
  api.add_files('src/util.coffee', ['server']);
  api.add_files('src/query.coffee', ['server']);
  api.add_files('src/search.coffee', ['server']);
  api.add_files('src/cursor.coffee', ['server']);
  api.add_files('src/collections/base.coffee', ['server']);
  api.add_files('src/collections/index.coffee', ['server']);
  api.add_files('src/collections/search.coffee', ['server']);
  api.add_files('src/client.coffee', ['client']);
  api.add_files('src/main.coffee', ['client', 'server']);
  api.export('Meds');
});

Package.on_test(function(api){
  api.use(['coffeescript', 'meds', 'munit', 'sinon', 'minimongo']);
  api.add_files('tests/bios-collection.coffee', ['client', 'server']);
  api.add_files('tests/bios.js', ['server']);
  api.add_files('tests/mock-sub.coffee', ['server']);
  api.add_files('tests/index.coffee', ['server']);
  api.add_files('tests/sort.coffee', ['server']);
  api.add_files('tests/fields.coffee', ['server']);
  api.add_files('tests/cursor.coffee', ['server']);
  api.add_files('tests/cursor-remove.coffee', ['server']);
  api.add_files('tests/cursor-change.coffee', ['server']);
  api.add_files('tests/client.coffee', ['client', 'server']);
});
