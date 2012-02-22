define "kopi/db/adapters/websql", (require, exports, module) ->

  support = require "kopi/utils/support"
  sql = require "kopi/db/adapters/sql"

  class WebSQLAdapter extends sql.SQLAdapter

    this.support = -> support.websql

  WebSQLAdapter: WebSQLAdapter
