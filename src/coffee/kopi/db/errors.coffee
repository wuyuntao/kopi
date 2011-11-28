kopi.module("kopi.db.errors")
  .require("kopi.exceptions")
  .define (exports, exceptions) ->

    class DuplicatePrimaryKeyError extends exceptions.Exception
      constructor: (name) ->
        super("Primary key field is already defined. #{name}")

    exports.DuplicatePrimaryKeyError = DuplicatePrimaryKeyError
