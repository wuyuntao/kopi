kopi.module("kopi.tests.db.adapters.indexeddb")
  .require("qunit")
  .require("kopi.settings")
  .require("kopi.tests.db.fixtures")
  .require("kopi.db.adapters.indexeddb")
  .define (exports, q, settings, fixtures, indexeddb) ->

    # TODO Move to kopi.utils.browser or kopi.utils.support
    win = window
    indexedDB = indexeddb.indexedDB

    User = fixtures.User

    User.adapter "client", indexeddb.IndexedDBAdapter, primary: true

    User.init ->

      q.module "kopi.db.adapters.indexeddb"

      q.test "create user", ->
        registerAt = new Date(2012, 2, 1, 20)
        user = new fixtures.User
          id: 1
          name: "Alpha"
          email: "alpha@gmail.com"
          registerAt: registerAt
        q.stop()
        user.save (error, obj) ->
          q.equals obj.guid, user.guid
          q.equals obj.id, 1
          q.equals obj.name, "Alpha"
          q.equals obj.email, "alpha@gmail.com"
          q.equals obj.registerAt.getTime(), registerAt.getTime()

          req = indexedDB.open(settings.kopi.db.indexedDB.name)
          req.onsuccess = ->
            db = req.result
            trans = db.transaction([User.dbName()])
            store = trans.objectStore(User.dbName())
            req = store.get(obj.id)
            req.onsuccess = (e) ->
              value = req.result

              q.equals value.id, 1
              q.equals value.name, "Alpha"
              q.equals value.email, "alpha@gmail.com"
              q.equals value.registerAt, registerAt.getTime()
              q.start()

      q.test "retrieve count of user", ->

      q.test "retrieve one user", ->
        registerAt = new Date(2012, 2, 1, 20)
        q.stop()
        User.where(id: 1).one (error, user) ->
          q.equals user.id, 1
          q.equals user.name, "Alpha"
          q.equals user.email, "alpha@gmail.com"
          q.equals user.registerAt.getTime(), registerAt.getTime()
          q.start()

      q.test "retrieve all users", ->

      q.test "update user", ->
        registerAt = new Date(2012, 2, 2, 20)
        user = new fixtures.User
          id: 2
          name: "Beta"
          email: "beta@gmail.com"
          registerAt: new Date(2012, 2, 2, 10)
        q.stop()
        user.save (error, obj) ->
          fixtures.User.where(id: 2).one (error, user) ->
            user.name = "Gamma"
            user.email = "gamma@gmail.com"
            user.registerAt = registerAt
            user.save (error) ->
              q.equals user.name, "Gamma"
              q.equals user.email, "gamma@gmail.com"
              q.equals user.registerAt.getTime(), registerAt.getTime()

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
                  q.equals value.registerAt, registerAt.getTime()
                  q.start()

      q.test "destroy user", ->
        q.stop()
        fixtures.User.where(id: 1).one (error, user) ->
          user.destroy (error) ->
            req = indexedDB.open(settings.kopi.db.indexedDB.name)
            req.onsuccess = ->
              db = req.result
              trans = db.transaction([User.dbName()])
              store = trans.objectStore(User.dbName())
              req = store.get(user.id)
              req.onsuccess = (e) ->
                q.equals req.result, null
                q.start()
