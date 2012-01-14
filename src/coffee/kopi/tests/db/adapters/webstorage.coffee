kopi.module("kopi.tests.db.adapters.webstorage")
  .require("kopi.tests.db.fixtures")
  .require("kopi.db.adapters.webstorage")
  .define (exports, fixtures, webstorage) ->

    fixtures.User.adapters
      client:
        webstorage.StorageAdapater

    module "kopi.db.adapters.webstorage"

    test "create object", ->
      registerAt = new Date(2012, 2, 1, 20)
      user = new fixtures.User
        id: 1
        name: "Alpha"
        email: "alpha@gmail.com"
        registerAt: registerAt
      stop()
      user.save (error) ->
        equals user.id, 1
        equals user.name, "Alpha"
        equals user.email, "alpha@gmail.com"
        equals user.registerAt.getTime(), registerAt.getTime()

        key = "kopi:user:1"
        value = JSON.parse(localStorage.getItem(key))
        equals value.id, 1
        equals value.name, "Alpha"
        equals value.email, "alpha@gmail.com"
        equals value.registerAt, registerAt.getTime()
        start()

    test "update object", ->

    test "retrieve object", ->

    test "destroy object", ->
