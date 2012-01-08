kopi.module("kopi.db.errors")
  .require("kopi.exceptions")
  .define (exports, exceptions) ->

    class DoesNotExist extends exceptions.Exception

    class DuplicateModelNameError extends exceptions.Exception
      constructor: (model) ->
        super("Model #{model.name} is already defined.")

    class DuplicatePrimaryKeyError extends exceptions.Exception
      constructor: (name) ->
        super("Primary key field is already defined. #{name}")

    class PrimaryKeyNotFoundError extends exceptions.Exception
      constructor: (model) ->
        super("Primary key field is not defined in model #{model.name}")

    class RelatedModelNotFetched extends exceptions.Exception
      constructor: (model, pk) ->
        super("Related '#{model.name}' with primary key '#{pk}' not fetched.")

    exports.DoesNotExist = DoesNotExist
    exports.DuplicateModelNameError = DuplicateModelNameError
    exports.DuplicatePrimaryKeyError = DuplicatePrimaryKeyError
    exports.PrimaryKeyNotFoundError = PrimaryKeyNotFoundError
    exports.RelatedModelNotFetched = RelatedModelNotFetched
