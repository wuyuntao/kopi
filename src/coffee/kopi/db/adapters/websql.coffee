kopi.module("kopi.db.adapters.websql")
  .require("kopi.db.adapters.sql")
  .define (exports, sql) ->

    class WebSQLAdapter extends sql.SQLAdapter

    exports.WebSQLAdapter = WebSQLAdapter
