kopi.module("kopi.db.adapters.android")
  .require("kopi.db.adapters.sql")
  .define (exports, sql) ->

    class AndroidSQLAdapter extends sql.SQLAdapter

    exports.AndroidSQLAdapter = AndroidSQLAdapter
