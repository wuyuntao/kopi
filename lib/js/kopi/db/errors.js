(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/db/errors", function(require, exports, module) {
    var AdapterNotFound, DoesNotExist, ModelError, ModelNameDuplicated, PrimaryAdapterNotFound, PrimaryKeyDuplicated, PrimaryKeyNotFound, RelatedModelNotFetched, exceptions;
    exceptions = require("kopi/exceptions");
    ModelError = (function(_super) {

      __extends(ModelError, _super);

      function ModelError(model, message) {
        if (!message) {
          message = model;
          model = null;
        }
        this.name = model ? model.name : this.constructor.name;
        this.message = message;
      }

      return ModelError;

    })(exceptions.Exception);
    PrimaryAdapterNotFound = (function(_super) {

      __extends(PrimaryAdapterNotFound, _super);

      function PrimaryAdapterNotFound(model) {
        PrimaryAdapterNotFound.__super__.constructor.call(this, model, "Primary adapter is not found");
      }

      return PrimaryAdapterNotFound;

    })(ModelError);
    AdapterNotFound = (function(_super) {

      __extends(AdapterNotFound, _super);

      function AdapterNotFound(model, adapter) {
        AdapterNotFound.__super__.constructor.call(this, model, "Adapter '" + adapter + "' is not defined");
      }

      return AdapterNotFound;

    })(ModelError);
    DoesNotExist = (function(_super) {

      __extends(DoesNotExist, _super);

      function DoesNotExist() {
        return DoesNotExist.__super__.constructor.apply(this, arguments);
      }

      return DoesNotExist;

    })(ModelError);
    ModelNameDuplicated = (function(_super) {

      __extends(ModelNameDuplicated, _super);

      function ModelNameDuplicated(model) {
        ModelNameDuplicated.__super__.constructor.call(this, "Model " + model.name + " is already defined.");
      }

      return ModelNameDuplicated;

    })(ModelError);
    PrimaryKeyDuplicated = (function(_super) {

      __extends(PrimaryKeyDuplicated, _super);

      function PrimaryKeyDuplicated(model, name) {
        PrimaryKeyDuplicated.__super__.constructor.call(this, model, "Primary key field is already defined.");
      }

      return PrimaryKeyDuplicated;

    })(ModelError);
    PrimaryKeyNotFound = (function(_super) {

      __extends(PrimaryKeyNotFound, _super);

      function PrimaryKeyNotFound(model) {
        PrimaryKeyNotFound.__super__.constructor.call(this, model, "Primary key field is not defined.");
      }

      return PrimaryKeyNotFound;

    })(ModelError);
    RelatedModelNotFetched = (function(_super) {

      __extends(RelatedModelNotFetched, _super);

      function RelatedModelNotFetched(model, pk) {
        RelatedModelNotFetched.__super__.constructor.call(this, model, "Related '" + model.name + "' with primary key '" + pk + "' not fetched.");
      }

      return RelatedModelNotFetched;

    })(ModelError);
    return {
      ModelError: ModelError,
      PrimaryAdapterNotFound: PrimaryAdapterNotFound,
      AdapterNotFound: AdapterNotFound,
      DoesNotExist: DoesNotExist,
      ModelNameDuplicated: ModelNameDuplicated,
      PrimaryKeyDuplicated: PrimaryKeyDuplicated,
      PrimaryKeyNotFound: PrimaryKeyNotFound,
      RelatedModelNotFetched: RelatedModelNotFetched
    };
  });

}).call(this);
