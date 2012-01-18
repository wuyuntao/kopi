kopi.module("kopi.tests.db.adapters.webstorage")
  .require("kopi.tests.db.fixtures")
  .require("kopi.db.adapters.webstorage")
  .define (exports, fixtures, webstorage) ->

    fixtures.User.adapter "client", webstorage.StorageAdapater, primary: true

    module "kopi.db.adapters.webstorage"

    test "create user", ->
      registerAt = new Date(2012, 2, 1, 20)
      user = new fixtures.User
        id: 1
        name: "Alpha"
        email: "alpha@gmail.com"
        registerAt: registerAt
      stop()
      user.save (error, obj) ->
        equals obj.guid, user.guid
        equals obj.id, 1
        equals obj.name, "Alpha"
        equals obj.email, "alpha@gmail.com"
        equals obj.registerAt.getTime(), registerAt.getTime()

        key = "kopi:user:1"
        value = JSON.parse(localStorage.getItem(key))
        equals value.id, 1
        equals value.name, "Alpha"
        equals value.email, "alpha@gmail.com"
        equals value.registerAt, registerAt.getTime()
        start()

    test "retrieve count of user", ->

    test "retrieve one user", ->
      registerAt = new Date(2012, 2, 1, 20)
      stop()
      fixtures.User.where(id: 1).one (error, user) ->
        equals user.id, 1
        equals user.name, "Alpha"
        equals user.email, "alpha@gmail.com"
        equals user.registerAt.getTime(), registerAt.getTime()
        start()

    test "retrieve all users", ->

    test "update user", ->
      registerAt = new Date(2012, 2, 2, 20)
      user = new fixtures.User
        id: 2
        name: "Beta"
        email: "beta@gmail.com"
        registerAt: new Date(2012, 2, 2, 10)
      user.save (error, obj) ->
        fixtures.User.where(id: 2).one (error, user) ->
          user.name = "Gamma"
          user.email = "gamma@gmail.com"
          user.registerAt = registerAt
          stop()
          user.save (error) ->
            equals user.name, "Gamma"
            equals user.email, "gamma@gmail.com"
            equals user.registerAt.getTime(), registerAt.getTime()

            key = "kopi:user:2"
            value = JSON.parse(localStorage.getItem(key))
            equals value.id, 2
            equals value.name, "Gamma"
            equals value.email, "gamma@gmail.com"
            equals value.registerAt, registerAt.getTime()
            start()

    test "destroy user", ->
      stop()
      fixtures.User.where(id: 1).one (error, user) ->
        user.destroy (error) ->
          key = "kopi:user:1"
          value = localStorage.getItem(key)
          equals value, null
          start()
