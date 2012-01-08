kopi.module("kopi.tests.db.adapters.webstorage")
  .require("kopi.tests.db.fixtures")
  .require("kopi.db.adapters.webstorage")
  .define (exports, fixtures, webstorage) ->

    fixtures.User.adapters
      client:
        webstorage.StorageAdapater

    module "kopi.db.adapters.webstorage"

    test "create object", ->
      user = new fixtures.User
        id: 1
        name: "Alpha"
        email: "alpha@gmail.com"
        registerAt: new Date(2012, 2, 1, 20)

    test "update object", ->

    test "retrieve object", ->

    test "destroy object", ->
