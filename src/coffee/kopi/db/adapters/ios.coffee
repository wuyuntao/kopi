kopi.module("kopi.db.adapters.ios")
  .require("kopi.db.adapters.sql")
  .define (exports, sql) ->

    class IOSSQLAdapter extends sql.SQLAdapter

    exports.IOSSQLAdapter = IOSSQLAdapter
