define "kopi/tests/db/adapters/indexeddb", (require, exports, module) ->

  q = require "qunit"
  settings = require "kopi/settings"
  fixtures = require "kopi/tests/db/fixtures"
  indexeddb = require "kopi/db/adapters/indexeddb"

  User = fixtures.User

  User.adapter "client", indexeddb.IndexedDBAdapter, primary: true

  CHRISMAS = new Date(2012, 12, 25, 20)
  NEW_YEAR = new Date(2012, 1, 1, 20)
  VALENTINE = new Date(2012, 2, 14, 20)

  ensureUser = (id, name, email, registerAt, fn) ->
    User.where(id: id).one (error, user) ->
      if error or user
        fn(error, user) if fn
        return

      user = new User id: id, name: name, email: email, registerAt: registerAt
      user.save fn

  ensureUsers = (fn) ->
    ensureUser 1, "Alpha", "alpha@gmail.com", CHRISMAS, ->
      ensureUser 2, "Beta", "beta@gmail.com", VALENTINE, ->
        ensureUser 3, "Delta", "delta@gmail.com", NEW_YEAR, ->
          fn()

  countUsers = (fn) ->
    User.count (error, count) ->
      q.equals count, 3
      fn() if fn

  retrieveOneUser = (fn) ->
    User.where(id: 3).one (error, user) ->
      q.equals user.id, 3
      q.equals user.name, "Delta"
      q.equals user.email, "delta@gmail.com"
      q.equals user.registerAt.getTime(), NEW_YEAR.getTime()
      fn() if fn

  retrieveAllUsers = (fn) ->
    User.all (error, users) ->
      q.equals users.length, 3
      q.equals users[0].id, 1
      q.equals users[2].id, 3

      # Test sort
      User.sort(id: false).all (error, users) ->
        q.equals users.length, 3
        q.equals users[0].id, 3
        q.equals users[2].id, 1

        # Test skip
        User.skip(1).all (error, users) ->
          q.equals users.length, 2
          q.equals users[0].id, 2
          q.equals users[1].id, 3

          # Test limit
          User.limit(1).all (error, users) ->
            q.equals users.length, 1
            q.equals users[0].id, 1
            fn() if fn

  retrieveUsersWithAdvancedQuerying = (fn) ->
    # Test primary key and lower bound querying
    User.where(id: {gte: 2}).all (error, users) ->
      q.equals users.length, 2
      q.equals users[0].id, 2
      q.equals users[1].id, 3

      # Test index and upper bound querying
      User.where(name: {lt: "Beta"}).all (error, users) ->
        q.equals users.length, 1
        q.equals users[0].id, 1

        # Test range querying
        User.where(registerAt: {gt: NEW_YEAR, lte: CHRISMAS}).all (error, users) ->
          q.equals users.length, 2
          # q.equals users[0].id, 2
          # q.equals users[1].id, 1
          fn() if fn

  updateOneUser = (fn) ->
    User.where(id: 2).one (error, user) ->
      user.name = "Gamma"
      user.email = "gamma@gmail.com"
      user.save (error) ->
        q.equals user.name, "Gamma"
        q.equals user.email, "gamma@gmail.com"

        req = indexedDB.open(settings.kopi.db.indexedDB.name)
        req.onsuccess = ->
          db = req.result
          trans = db.transaction([User.dbName()])
          store = trans.objectStore(User.dbName())
          req = store.get(user.id)
          req.onsuccess = (e) ->
            value = req.result
            q.equals value.id, 2
            q.equals value.name, "Gamma"
            q.equals value.email, "gamma@gmail.com"
            fn() if fn

  destroyOneUser = (fn) ->
    fixtures.User.where(id: 1).one (error, user) ->
      user.destroy (error) ->
        req = indexedDB.open(settings.kopi.db.indexedDB.name)
        req.onsuccess = ->
          db = req.result
          trans = db.transaction([User.dbName()])
          store = trans.objectStore(User.dbName())
          req = store.get(user.id)
          req.onsuccess = (e) ->
            q.ok !req.result
            fn() if fn

  User.init ->
    ensureUsers ->

      q.module "kopi/db/adapters/indexeddb"

      q.test "count users", ->
        q.stop()
        countUsers -> q.start()

      q.test "retrieve one user", ->
        q.stop()
        retrieveOneUser -> q.start()

      q.test "retrieve all users", ->
        q.stop()
        retrieveAllUsers -> q.start()

      q.test "retrieve users with advanced querying", ->
        q.stop()
        retrieveUsersWithAdvancedQuerying -> q.start()

      q.test "update one user", ->
        q.stop()
        updateOneUser -> q.start()

      q.test "destroy one user", ->
        q.stop()
        destroyOneUser -> q.start()
