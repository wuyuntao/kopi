kopi.module("kopi.db.sync")
  .require("kopi.db.collections")
  .require("kopi.db.models")
  .define (exports, collections, models) ->

    ###
    负责对模型和服务器进行同步
    ###
    class Sync

    exports.Sync = Sync
