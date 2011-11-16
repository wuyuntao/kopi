kopi.module("kopi.db.errors")
  .require("kopi.exceptions")
  .define (exports, exceptions) ->

    class DuplicatePkField extends exceptions.Exception
      constructor: (name) ->
        super("Primary key field is already defined. #{name}")

    exports.DuplicatePrimaryKey = DuplicatePrimaryKey
