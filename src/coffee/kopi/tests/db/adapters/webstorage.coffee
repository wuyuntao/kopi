define "kopi/tests/db/adapters/webstorage", (require, exports, module) ->

  fixtures = require "kopi/tests/db/fixtures"
  webstorage = require "kopi/db/adapters/webstorage"

  fixtures.User.adapter "client", webstorage.StorageAdapater, primary: true

  q.module "kopi/db/adapters/webstorage"

  q.test "create user", ->
    registerAt = new Date(2012, 2, 1, 20)
    user = new fixtures.User
      id: 1
      name: "Alpha"
      email: "alpha@gmail.com"
      registerAt: registerAt
    stop()
    user.save (error, obj) ->
      q.equals obj.guid, user.guid
      q.equals obj.id, 1
      q.equals obj.name, "Alpha"
      q.equals obj.email, "alpha@gmail.com"
      q.equals obj.registerAt.getTime(), registerAt.getTime()

      key = "kopi:user:1"
      value = JSON.parse(localStorage.getItem(key))
      q.equals value.id, 1
      q.equals value.name, "Alpha"
      q.equals value.email, "alpha@gmail.com"
      q.equals value.registerAt, registerAt.getTime()
      start()

  q.test "retrieve count of user", ->

  q.test "retrieve one user", ->
    registerAt = new Date(2012, 2, 1, 20)
    stop()
    fixtures.User.where(id: 1).one (error, user) ->
      q.equals user.id, 1
      q.equals user.name, "Alpha"
      q.equals user.email, "alpha@gmail.com"
      q.equals user.registerAt.getTime(), registerAt.getTime()
      start()

  q.test "retrieve all users", ->

  q.test "update user", ->
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
          q.equals user.name, "Gamma"
          q.equals user.email, "gamma@gmail.com"
          q.equals user.registerAt.getTime(), registerAt.getTime()

          key = "kopi:user:2"
          value = JSON.parse(localStorage.getItem(key))
          q.equals value.id, 2
          q.equals value.name, "Gamma"
          q.equals value.email, "gamma@gmail.com"
          q.equals value.registerAt, registerAt.getTime()
          start()

  q.test "destroy user", ->
    stop()
    fixtures.User.where(id: 1).one (error, user) ->
      user.destroy (error) ->
        key = "kopi:user:1"
        value = localStorage.getItem(key)
        q.equals value, null
        start()
