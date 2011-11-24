kopi.module("kopi.db.adapters.kv")
  .require("kopi.db.adapters.client")
  .define (exports, module) ->

    ###
    Adapter for Key/Value Databases like local storage, memcached, redis, etc.

    Model definition

      class app.user.User extends Model
        cls = this
        cls.fields
          sid:
            type: Model.INTEGER
            primary: true
          login:
            type: Model.STRING
            index: true
          avatar:
            type: Model.STRING

    Data Structure

      == key ==                   == value ==
      kopi:user:1                 {"sid":1,"login":"kobe","avatar":null}
      kopi:user:2                 {"sid":2,"login":"kd35","avatar":"/avatars/kd35.jpg"}
      kopi:user:index:pk          {"1":1,"2":2}
      kopi:user:index:login       {"kopi":1,"kd35":2}

    NOTE
      Key/Value adapter does not support multiple fields querying
      Key/Value adapter does not support non-unique index
    ###
    class KeyValueAdapter extends client.ClientAdapter

      create: (query, fn) ->

      retrieve: (query, fn) ->

      update: (query, fn) ->

      destroy: (query, fn) ->

    exports.KeyValueAdapter = KeyValueAdapter
