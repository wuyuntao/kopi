kopi.module("kopi.db.errors")
  .require("kopi.exceptions")
  .define (exports, exceptions) ->

    class ModelError extends exceptions.Exception
      constructor: (model, message) ->
        if not message
          message = model
          model = null
        this.name = if model then model.name else this.constructor.name
        this.message = message

    class PrimaryAdapterNotFound extends ModelError
      constructor: (model) ->
        super(model, "Primary adapter is not found")

    class AdapterNotFound extends ModelError
      constructor: (model, adapter) ->
        super(model, "Adapter '#{adapter}' is not defined")

    class DoesNotExist extends ModelError

    class ModelNameDuplicated extends ModelError
      constructor: (model) ->
        super("Model #{model.name} is already defined.")

    class PrimaryKeyDuplicated extends ModelError
      constructor: (model, name) ->
        super(model, "Primary key field is already defined.")

    class PrimaryKeyNotFound extends ModelError
      constructor: (model) ->
        super(model, "Primary key field is not defined.")

    class RelatedModelNotFetched extends ModelError
      constructor: (model, pk) ->
        super(model, "Related '#{model.name}' with primary key '#{pk}' not fetched.")

    exports.ModelError = ModelError
    exports.PrimaryAdapterNotFound = PrimaryAdapterNotFound
    exports.AdapterNotFound = AdapterNotFound
    exports.DoesNotExist = DoesNotExist
    exports.ModelNameDuplicated = ModelNameDuplicated
    exports.PrimaryKeyDuplicated = PrimaryKeyDuplicated
    exports.PrimaryKeyNotFound = PrimaryKeyNotFound
    exports.RelatedModelNotFetched = RelatedModelNotFetched
