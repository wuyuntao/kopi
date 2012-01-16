kopi.module("kopi.tests.db.adapters.webstorage")
  .require("kopi.tests.db.fixtures")
  .require("kopi.db.adapters.webstorage")
  .define (exports, fixtures, webstorage) ->

    fixtures.User.adapter "client", webstorage.StorageAdapater, primary: true

    module "kopi.db.adapters.webstorage"

    test "create object", ->
      registerAt = new Date(2012, 2, 1, 20)
      user = new fixtures.User
        id: 1
        name: "Alpha"
        email: "alpha@gmail.com"
        registerAt: registerAt
      stop()
      user.save (error, obj) ->
        equals obj.id, 1
        equals obj.name, "Alpha"
        equals obj.email, "alpha@gmail.com"
        equals obj.registerAt.getTime(), registerAt.getTime()

        key = "kopi:user:1"
        value = JSON.parse(localStorage.getItem(key))
        equals value.id, 1
        equals value.name, "Alpha"
        equals value.email, "alpha@gmail.com"
        equals value.registerAt, registerAt.toISOString()
        start()

    test "retrieve object", ->
      registerAt = new Date(2012, 2, 1, 20)
      stop()
      fixtures.User.get id: 1, (error, user) ->
        equals user.id, 1
        equals user.name, "Alpha"
        equals user.email, "alpha@gmail.com"
        equals user.registerAt.getTime(), registerAt.getTime()
        start()

    test "update object", ->
      registerAt = new Date(2012, 2, 1, 30)
      stop()
      fixtures.User.get id: 1, (error, user) ->
        user.name = "Beta"
        user.email = "beta@gmail.com"
        user.registerAt = registerAt
        user.save (error) ->
          equals user.name, "Beta"
          equals user.email, "beta@gmail.com"
          equals user.registerAt.getTime(), registerAt.getTime()

          key = "kopi:user:1"
          value = JSON.parse(localStorage.getItem(key))
          equals value.id, 1
          equals value.name, "Beta"
          equals value.email, "beta@gmail.com"
          equals value.registerAt, registerAt.getTime()
          start()

    test "destroy object", ->
      stop()
      fixtures.User.get id: 1, (error, user) ->
        user.destroy (error) ->

        key = "kopi:user:1"
        value = localStorage.getItem(key)
        equals value, null
        start()
