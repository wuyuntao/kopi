define "kopi/tests/db/adapters/memory", (require, exports, module) ->

  q = require "qunit"
  fixtures = require "kopi/tests/db/fixtures"
  memory = require "kopi/db/adapters/memory"
  storage = require("kopi/utils/storage").memoryStorage

  fixtures.User.adapter "client", memory.MemoryAdapter, primary: true

  q.module "kopi/db/adapters/memory"

  q.test "create user", ->
    registerAt = new Date(2012, 2, 1, 20)
    user = new fixtures.User
      id: 1
      name: "Alpha"
      email: "alpha@gmail.com"
      registerAt: registerAt
    q.stop()
    user.save (error, obj) ->
      q.equal obj.guid, user.guid
      q.equal obj.id, 1
      q.equal obj.name, "Alpha"
      q.equal obj.email, "alpha@gmail.com"
      q.equal obj.registerAt.getTime(), registerAt.getTime()

      key = "kopi:user:1"
      value = storage.getItem(key)
      q.equal value.id, 1
      q.equal value.name, "Alpha"
      q.equal value.email, "alpha@gmail.com"
      q.equal value.registerAt.getTime(), registerAt.getTime()
      q.start()

  # q.test "retrieve count of user", ->

  q.test "retrieve one user", ->
    registerAt = new Date(2012, 2, 1, 20)
    q.stop()
    fixtures.User.where(id: 1).one (error, user) ->
      q.equal user.id, 1
      q.equal user.name, "Alpha"
      q.equal user.email, "alpha@gmail.com"
      q.equal user.registerAt.getTime(), registerAt.getTime()
      q.start()

  # q.test "retrieve all users", ->

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
        console.log user
        user.name = "Gamma"
        user.email = "gamma@gmail.com"
        user.registerAt = registerAt
        user.save (error) ->
          q.equal user.name, "Gamma"
          q.equal user.email, "gamma@gmail.com"
          q.equal user.registerAt.getTime(), registerAt.getTime()

          key = "kopi:user:2"
          value = storage.getItem(key)
          q.equal value.id, 2
          q.equal value.name, "Gamma"
          q.equal value.email, "gamma@gmail.com"
          q.equal value.registerAt.getTime(), registerAt.getTime()
          q.start()

  q.test "destroy user", ->
    q.stop()
    fixtures.User.where(id: 1).one (error, user) ->
      user.destroy (error) ->
        key = "kopi:user:1"
        value = storage.getItem(key)
        q.equal value, null
        q.start()
