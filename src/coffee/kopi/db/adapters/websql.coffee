kopi.module("kopi.db.adapters.websql")
  .require("kopi.utils.support")
  .require("kopi.db.adapters.sql")
  .define (exports, support, sql) ->

    class WebSQLAdapter extends sql.SQLAdapter

      this.support = -> support.websql

    exports.WebSQLAdapter = WebSQLAdapter
