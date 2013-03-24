(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __slice = [].slice;

  define("kopi/db/queries", function(require, exports, module) {
    var ACTIONS, ALL, BaseQuery, BaseRetriveQuery, COUNT, CREATE, CreateQuery, DESTROY, DestroyQuery, EQ, GT, GTE, ILIKE, IN, IS, LIKE, LIMIT, LT, LTE, NE, NIN, ONE, ONLY, QueryError, RAW, RETRIEVE, RawQuery, RetrieveQuery, SKIP, SORT, UPDATE, UpdateQuery, WHERE, array, exceptions, klass, number, object, utils;
    exceptions = require("kopi/exceptions");
    utils = require("kopi/utils");
    klass = require("kopi/utils/klass");
    number = require("kopi/utils/number");
    object = require("kopi/utils/object");
    array = require("kopi/utils/array");
    /*
      Some query related exception
    */

    QueryError = (function(_super) {

      __extends(QueryError, _super);

      function QueryError() {
        return QueryError.__super__.constructor.apply(this, arguments);
      }

      return QueryError;

    })(exceptions.Exception);
    CREATE = "create";
    RETRIEVE = "retrieve";
    UPDATE = "update";
    DESTROY = "destroy";
    RAW = "raw";
    ACTIONS = [CREATE, RETRIEVE, UPDATE, DESTROY, RAW];
    ONLY = "only";
    WHERE = "where";
    SORT = "sort";
    SKIP = "skip";
    LIMIT = "limit";
    COUNT = "count";
    ONE = "one";
    ALL = "all";
    LT = "lt";
    LTE = "lte";
    GT = "gt";
    GTE = "gte";
    EQ = "eq";
    NE = "ne";
    IN = "in";
    NIN = "nin";
    IS = "IS";
    LIKE = "LIKE";
    ILIKE = "ILIKE";
    /*
      Kopi provides a query API similar to MongoDB.
    
      Define a query to retrieve books which are collected by some user
    
        base = new RetrieveQuery(Book)
          .only("sid", "title")
          .where(userId: user.sid)
          .sort(collectedAt: false)
        count = base.clone()
          .count(true)
        query = base.clone()
          .skip(10)
          .limit(10)
    
      Define a query with advanced condition filters
    
        query = new RetrieveQuery(Book)
          .where
            userId:
              in: [1, 3, 5]
            registerAt:
              lte: new Date(2011, 12, 1)
              gt: new Date(2011, 11, 1)
            lastName:
              like: /smith|johnson/
            firstName:
              ne: "josh"
    
      Define a query to create a comment of a book
        query = new CreateQuery(Comment)
          .attrs(bookId: book.sid, body: "Then again")
    
      Define a query to update multiple comments
        query = new UpdateQuery(Comment)
          .where(userId: user.sid, bookId: book.sid)
          .attrs(privacy: Comment.PRIVACY_PUBLIC)
    */

    BaseQuery = (function() {
      var proto;

      BaseQuery.METHODS = [];

      proto = BaseQuery.prototype;

      klass.accessor(proto, "action");

      function BaseQuery(model, criteria) {
        var cls, method, self, _i, _len, _ref;
        cls = this.constructor;
        self = this;
        if (!model) {
          throw new exceptions.ValueError("Model must be a subclass of kopi.db.models.Model");
        }
        self.model = model;
        if (criteria) {
          _ref = cls.METHODS;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            method = _ref[_i];
            if (method in criteria) {
              self[method](criteria[method]);
            }
          }
        }
      }

      BaseQuery.prototype.clone = function() {
        throw new exceptions.NotImplementedError();
      };

      BaseQuery.prototype.params = function() {
        return '';
      };

      BaseQuery.prototype.sql = function() {
        throw new exceptions.NotImplementedError();
      };

      BaseQuery.prototype.criteria = function() {
        var cls, criteria, method, self, value, _i, _len, _ref;
        cls = this.constructor;
        self = this;
        criteria = {};
        _ref = cls.METHODS;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          method = _ref[_i];
          value = self[method]();
          if (value) {
            criteria[method] = value;
          }
        }
        return criteria;
      };

      BaseQuery.prototype.execute = function(fn, type) {
        var adapter, self;
        self = this;
        adapter = self.model.prepare().adapter(type);
        adapter[self._action](self, fn);
        return this;
      };

      return BaseQuery;

    })();
    CreateQuery = (function(_super) {
      var proto;

      __extends(CreateQuery, _super);

      proto = CreateQuery.prototype;

      klass.accessor(proto, "attrs", {
        value: {},
        set: function(attrs) {
          if (this._attrs) {
            return object.extend(this._attrs, attrs);
          } else {
            return this._attrs = attrs;
          }
        }
      });

      function CreateQuery(model, attrs) {
        if (attrs == null) {
          attrs = {};
        }
        this.action(CREATE).attrs(attrs);
        CreateQuery.__super__.constructor.call(this, model);
      }

      CreateQuery.prototype.params = function() {
        return {
          attrs: JSON.stringify(this._attrs)
        };
      };

      CreateQuery.prototype.clone = function() {
        return new this.constructor(this.model, this._attrs);
      };

      CreateQuery.prototype.pk = function() {
        var self;
        self = this;
        return self._attrs[self.model.meta().pk];
      };

      return CreateQuery;

    })(BaseQuery);
    BaseRetriveQuery = (function(_super) {
      var kls, proto;

      __extends(BaseRetriveQuery, _super);

      kls = BaseRetriveQuery;

      kls.METHODS = [WHERE, SKIP, LIMIT];

      kls.OPERATIONS = [LT, LTE, GT, GTE, EQ, NE, IN, NIN, IS, LIKE, ILIKE];

      proto = BaseRetriveQuery.prototype;

      klass.accessor(proto, "where", {
        value: {},
        set: function(where) {
          var field, operations, _base, _results;
          this._where || (this._where = {});
          _results = [];
          for (field in where) {
            operations = where[field];
            (_base = this._where)[field] || (_base[field] = {});
            if (!this._isOpertions(operations)) {
              operations = {
                eq: operations
              };
            }
            _results.push(object.extend(this._where[field], operations));
          }
          return _results;
        }
      });

      klass.accessor(proto, "skip", {
        set: function(skip) {
          if (number.isNumber(skip)) {
            return this._skip = skip;
          }
        }
      });

      klass.accessor(proto, "limit", {
        set: function(limit) {
          if (number.isNumber(limit)) {
            return this._limit = limit;
          }
        }
      });

      function BaseRetriveQuery(model, criteria) {
        var self;
        self = this;
        BaseRetriveQuery.__super__.constructor.call(this, model, criteria);
      }

      /*
          If value is an hash and all keys are operation keywords,
          value is considered as a operation hash
      
          TODO Need to optimize performance?
      */


      BaseRetriveQuery.prototype._isOpertions = function(obj) {
        var key, value;
        if (object.isObject(obj)) {
          for (key in obj) {
            value = obj[key];
            if (__indexOf.call(this.constructor.OPERATIONS, key) < 0) {
              return false;
            }
          }
          return true;
        }
        return false;
      };

      BaseRetriveQuery.prototype.clone = function() {
        var cls, self;
        cls = this.constructor;
        self = this;
        return new cls(self.model, self.criteria());
      };

      BaseRetriveQuery.prototype.pk = function() {
        var criteria, pk, self;
        self = this;
        criteria = self.criteria();
        try {
          pk = criteria.pk.eq;
        } catch (e) {
          try {
            pk = criteria.where[self.model.meta().pk].eq;
          } catch (e) {
            pk = null;
          }
        }
        return pk;
      };

      return BaseRetriveQuery;

    })(BaseQuery);
    RetrieveQuery = (function(_super) {
      var proto;

      __extends(RetrieveQuery, _super);

      RetrieveQuery.METHODS = [ONLY, WHERE, SORT, SKIP, LIMIT, COUNT];

      RetrieveQuery.ALL = RetrieveQuery.METHODS.concat([ONE, ALL]);

      proto = RetrieveQuery.prototype;

      klass.accessor(proto, "only", {
        set: function() {
          return this._only = arguments;
        }
      });

      klass.accessor(proto, "sort", {
        value: {},
        set: function(sort) {
          this._sort || (this._sort = {});
          return object.extend(this._sort, sort);
        }
      });

      function RetrieveQuery(model, criteria) {
        var self;
        self = this;
        self.action(RETRIEVE);
        self._count = false;
        RetrieveQuery.__super__.constructor.call(this, model, criteria);
      }

      RetrieveQuery.prototype.count = function(fn, type) {
        var self;
        self = this;
        if (!arguments.length) {
          return self._count;
        }
        self._count = true;
        return self.execute(fn, type);
      };

      RetrieveQuery.prototype.one = function(fn, type) {
        var retrieveFn, self;
        self = this;
        self._limit = 1;
        retrieveFn = function(error, result) {
          var model;
          if (error) {
            if (fn) {
              fn(error, result);
            }
            return;
          }
          if (array.isArray(result)) {
            result = result[0];
          }
          if (result) {
            model = new self.model(result);
            model.isNew = false;
          } else {
            model = null;
          }
          if (fn) {
            return fn(error, model);
          }
        };
        return self.execute(retrieveFn, type);
      };

      RetrieveQuery.prototype.all = function(fn, type) {
        var retrieveFn, self;
        self = this;
        retrieveFn = function(error, result) {
          var collection, entry, i, model, _i, _len;
          if (error) {
            if (fn) {
              fn(error, result);
            }
            return;
          }
          collection = [];
          if (result.length > 0) {
            for (i = _i = 0, _len = result.length; _i < _len; i = ++_i) {
              entry = result[i];
              model = new self.model(entry);
              model.isNew = false;
              collection.push(model);
            }
          }
          if (fn) {
            return fn(error, collection);
          }
        };
        return self.execute(retrieveFn, type);
      };

      return RetrieveQuery;

    })(BaseRetriveQuery);
    UpdateQuery = (function(_super) {
      var proto;

      __extends(UpdateQuery, _super);

      proto = UpdateQuery.prototype;

      klass.accessor(proto, "attrs", {
        value: {},
        set: function(attrs) {
          if (this._attrs) {
            return object.extend(this._attrs, attrs);
          } else {
            return this._attrs = attrs;
          }
        }
      });

      function UpdateQuery(model, criteria, attrs) {
        if (attrs == null) {
          attrs = {};
        }
        this.action(UPDATE).attrs(attrs);
        UpdateQuery.__super__.constructor.call(this, model, criteria);
      }

      UpdateQuery.prototype.clone = function() {
        var cls, self;
        cls = this.constructor;
        self = this;
        return new cls(self.model, self.criteria(), self._attrs);
      };

      return UpdateQuery;

    })(BaseRetriveQuery);
    DestroyQuery = (function(_super) {

      __extends(DestroyQuery, _super);

      function DestroyQuery(model, criteria) {
        this.action(DESTROY);
        DestroyQuery.__super__.constructor.call(this, model, criteria);
      }

      return DestroyQuery;

    })(BaseRetriveQuery);
    RawQuery = (function(_super) {

      __extends(RawQuery, _super);

      klass.accessor(RawQuery.prototype, "args");

      function RawQuery() {
        var args, model;
        model = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        this.action(RAW);
        this.args(args);
        RawQuery.__super__.constructor.call(this, model);
      }

      RawQuery.prototype.clone = function() {
        return (function(func, args, ctor) {
          ctor.prototype = func.prototype;
          var child = new ctor, result = func.apply(child, args), t = typeof result;
          return t == "object" || t == "function" ? result || child : child;
        })(this.constructor, [this.model].concat(__slice.call(this.args())), function(){});
      };

      return RawQuery;

    })(BaseQuery);
    return {
      CREATE: CREATE,
      RETRIEVE: RETRIEVE,
      UPDATE: UPDATE,
      DESTROY: DESTROY,
      RAW: RAW,
      ACTIONS: ACTIONS,
      LT: LT,
      LTE: LTE,
      GT: GT,
      GTE: GTE,
      EQ: EQ,
      NE: IN,
      IN: IN,
      NIN: NIN,
      IS: IS,
      LIKE: LIKE,
      ILIKE: ILIKE,
      CreateQuery: CreateQuery,
      RetrieveQuery: RetrieveQuery,
      UpdateQuery: UpdateQuery,
      DestroyQuery: DestroyQuery,
      RawQuery: RawQuery
    };
  });

}).call(this);
