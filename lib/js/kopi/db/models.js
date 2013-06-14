(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  define("kopi/db/models", function(require, exports, module) {
    var DATETIME, FLOAT, INTEGER, JSON, Meta, Model, PRIMARY, STRING, TEXT, array, date, errors, events, exceptions, html, klass, logger, logging, object, queries, text, utils;

    exceptions = require("kopi/exceptions");
    events = require("kopi/events");
    logging = require("kopi/logging");
    utils = require("kopi/utils");
    array = require("kopi/utils/array");
    klass = require("kopi/utils/klass");
    html = require("kopi/utils/html");
    object = require("kopi/utils/object");
    text = require("kopi/utils/text");
    date = require("kopi/utils/date");
    queries = require("kopi/db/queries");
    errors = require("kopi/db/errors");
    logger = logging.logger(module.id);
    INTEGER = 0;
    STRING = 1;
    TEXT = 2;
    FLOAT = 3;
    DATETIME = 4;
    JSON = 5;
    PRIMARY = "primary";
    /*
    Meta class for all models
    */

    Meta = (function() {
      var meta;

      meta = {};

      Meta.get = function(model) {
        var m, name;

        name = model.modelName();
        m = meta[name];
        if (m) {
          if (m.model !== model) {
            throw new errors.ModelNameDuplicated(model);
          }
          return m;
        }
        return meta[name] = new Meta(model);
      };

      function Meta(model) {
        this.model = model;
        this.dbName = null;
        this.pk = null;
        this.fields = [];
        this.names = {};
        this.belongsTo = [];
        this.belongsToNames = {};
        this.hasMany = [];
        this.hasManyNames = {};
        this.hasAndBelongsToMany = [];
        this.adapters = {};
        this.defaultAdapterType = null;
        this.indexes = [];
      }

      Meta.prototype.prepare = function() {
        var field, model, modelMeta, name, pkName, relation, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;

        this.dbName || (this.dbName = this.model.dbName());
        _ref = this.fields;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          field = _ref[_i];
          this.names[field.name] = field;
        }
        _ref1 = this.belongsTo;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          relation = _ref1[_j];
          model = relation.model;
          if (text.isString(model)) {
            module = text.isString(relation.module) ? require(relation.module) : relation.module;
            model = relation.model = module[model];
          }
          name = relation.name;
          if (!name) {
            name = relation.name = text.camelize(model.modelName(), false);
          }
          modelMeta = model.meta();
          pkName = name + text.camelize(modelMeta.pk);
          field = object.clone(modelMeta.names[modelMeta.pk]);
          field.name = pkName;
          field.isBelongsTo = true;
          relation.pkName = pkName;
          delete field.primary;
          this.fields.push(field);
          this.names[pkName] = field;
          this.belongsToNames[name] = relation;
        }
        _ref2 = this.hasMany;
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          relation = _ref2[_k];
          model = relation.model;
          if (text.isString(model)) {
            module = text.isString(relation.module) ? require(relation.module) : relation.module;
            model = relation.model = module[model];
          }
          name = relation.name;
          if (!name) {
            name = relation.name = text.camelize(text.pluralize(model.modelName()), false);
          }
          this.hasManyNames[name] = relation;
        }
        if (!this.pk) {
          throw new errors.PrimaryKeyNotFound(this.model);
        }
        return this;
      };

      return Meta;

    })();
    /*
    Base class of all models
    
    Usage
    
      # Define blog model
      class Blog extends Model
        cls = this
    
        cls.adapter "server", RESTfulAdapter, primary: true
        cls.adapter "client", WebSQLAdapter
    
        cls.field "id", type: Model.INTEGER, primary: true
        cls.field "title", type: Model.STRING
        cls.field "description", type: Model.STRING
    
        cls.belongsTo "author.models.Author", name: "author"
        cls.hasMany Entry, name: "entries"
        cls.hasAndBelongsToMany Tag, name: "tags"
    
      saveFn = (error, blog) ->
        if not error
          # Blog is saved in local database successfully
    
      fetchFn = (error, blog) ->
        if not error
          # Save blog in local database
          blog.save saveFn, Blog.CLIENT
    
      # Fetch blog which id equals 1 from server
      Blog.get id: 1, fetchFn, Blog.SERVER
      # Or omit default adapter type
      Blog.get id: 1, fetchFn
    */

    Model = (function(_super) {
      var defineMethod, kls, method, _i, _len, _ref;

      __extends(Model, _super);

      kls = Model;

      klass.accessor(kls, "modelName", {
        get: function() {
          return this._modelName || (this._modelName = this.name);
        }
      });

      klass.accessor(kls, "dbName", {
        get: function() {
          var meta;

          meta = this.meta();
          return meta.dbName || (meta.dbName = this.modelName());
        },
        set: function(name) {
          var meta;

          meta = this.meta();
          return meta.dbName = name;
        }
      });

      kls.adapter = function(type, adapter, options) {
        var cls, meta, _name;

        if (type == null) {
          type = PRIMARY;
        }
        cls = this;
        meta = this.meta();
        if (!adapter) {
          adapter = meta.adapters[type];
          if (!adapter) {
            if (type === PRIMARY) {
              throw new errors.PrimaryAdapterNotFound(cls);
            }
          }
          return adapter;
        }
        if (!adapter.support(cls)) {
          logger.error("Adapter " + adapter.name + " is not available.");
          return cls;
        }
        cls[_name = text.underscore(type).toUpperCase()] || (cls[_name] = type);
        adapter = meta.adapters[type] = new adapter(options);
        if (options && options.primary) {
          meta.adapters.primary = adapter;
        }
        return cls;
      };

      /*
      Define a single field
      */


      kls.field = function(name, options) {
        var meta;

        if (options == null) {
          options = {};
        }
        meta = this.meta();
        if (text.isString(options)) {
          options = {
            type: options
          };
        }
        if (options.type == null) {
          options.type = STRING;
        }
        if (options.primary) {
          if (meta.pk && meta.pk !== name) {
            throw new errors.PrimaryKeyDuplicated(name);
          }
          meta.pk = name;
        }
        options.name = name;
        meta.fields.push(options);
        this._prepared = false;
        return this;
      };

      /*
      Define one-to-many relationship
      */


      kls.belongsTo = function(model, options) {
        var meta;

        if (options == null) {
          options = {};
        }
        meta = this.meta();
        options.model = model;
        meta.belongsTo.push(options);
        this._prepared = false;
        return this;
      };

      /*
      Define many-to-one relationship
      */


      kls.hasMany = function(model, options) {
        var meta;

        if (options == null) {
          options = {};
        }
        meta = this.meta();
        options.model = model;
        meta.hasMany.push(options);
        this._prepared = false;
        return this;
      };

      /*
      Define many-to-many relationship
      */


      kls.hasAndBelongsToMany = function(model, options) {
        var meta;

        if (options == null) {
          options = {};
        }
        meta = this.meta();
        options.model = model;
        meta.hasAndBelongsToMany.push(options);
        this._prepared = false;
        return this;
      };

      /*
      Define query index
      */


      kls.index = function(field) {
        var meta;

        meta = this.meta();
        meta.indexes || (meta.indexes = []);
        meta.indexes.push(field);
        this._prepared = false;
        return this;
      };

      /*
      Get meta for model
      */


      kls.meta = function() {
        return Meta.get(this);
      };

      /*
      Determine where two values equal to each other
      */


      kls._valueEquals = function(field, val1, val2) {
        var meta, type;

        meta = this.meta();
        type = meta.names[field].type;
        if (type === DATETIME) {
          val1 = date.isDate(val1) ? val1.getTime() : parseInt(val1);
          val2 = date.isDate(val2) ? val2.getTime() : parseInt(val2);
        }
        return val1 === val2;
      };

      /*
      Validates field definitions and creates some getter and setter methods for model
      */


      kls.prepare = function() {
        var cls, defineProp, field, meta, proto, relation, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;

        cls = this;
        if (cls._prepared) {
          return cls;
        }
        meta = cls.meta().prepare();
        proto = this.prototype;
        /*
        Define getter and setter for regular fields.
        
        e.g.
          book.title            # returns 'Book'
          book.title = 'Title'  # returns 'Title'
        */

        defineProp = function(field) {
          var getterFn, name, setterFn;

          name = field.name;
          getterFn = function() {
            return this._data[name];
          };
          setterFn = function(value) {
            var oldValue;

            oldValue = this[name];
            if (!cls._valueEquals(name, oldValue, value)) {
              this._data[name] = value;
              return this._dirty[name] = oldValue;
            }
          };
          return object.defineProperty(proto, name, {
            get: getterFn,
            set: setterFn
          });
        };
        _ref = meta.fields;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          field = _ref[_i];
          defineProp(field);
        }
        /*
        Define getter and setter for one-to-many relationships
        
        e.g.
          book.author                 # returns [Author 1]
          book.author = author2       # returns [Author 2]
        */

        defineProp = function(relation) {
          var getterFn, name, pkName, setterFn;

          name = relation.name;
          pkName = relation.pkName;
          getterFn = function() {
            var model;

            if (!this._data[pkName]) {
              return null;
            }
            model = this._belongsTo[name];
            if (model && model.pk() === this._data[pkName]) {
              return model;
            }
            throw new errors.RelatedModelNotFetched(cls, this.pk());
          };
          setterFn = function(value) {
            var oldPk, pk;

            oldPk = this._data[pkName];
            pk = value.pk ? value.pk() : value;
            this[pkName] = pk;
            if (!this._valueEquals(pkName, oldPk, pk)) {
              if (!value) {
                this._data[pkName] = null;
                this._dirty[pkName] = oldPk;
                this._belongsTo[name] = void 0;
              } else if (value.pk) {
                this._data[pkName] = value.pk();
                this._dirty[pkName] = oldPk;
                this._belongsTo[name] = value;
              } else {
                this._data[pkName] = value;
                this._dirty[pkName] = oldPk;
                this._belongsTo[name] = void 0;
              }
              return this.emit(cls.VALUE_CHANGE_EVENT, [this, name, value]);
            }
          };
          return object.defineProperty(proto, name, {
            get: getterFn,
            set: setterFn
          });
        };
        _ref1 = meta.belongsTo;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          relation = _ref1[_j];
          defineProp(relation);
        }
        /*
        Define getter and setter for many-to-one relationships
        
        e.g.
          author.books
        */

        defineProp = function(relation) {
          var getterFn, name, setterFn;

          name = relation.name;
          getterFn = function() {
            var collection, _base;

            collection = (_base = this._hasMany)[name] || (_base[name] = []);
            if (collection) {
              return collection;
            }
          };
          setterFn = function(value) {
            this._hasMany[name] = value;
            return this.emit(cls.VALUE_CHANGE_EVENT, [this, name, value]);
          };
          return object.defineProperty(proto, name, {
            get: getterFn,
            set: setterFn
          });
        };
        _ref2 = meta.hasMany;
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          relation = _ref2[_k];
          defineProp(relation);
        }
        cls._prepared = true;
        return cls;
      };

      /*
      Initialize database if neccessary
      @param {Function} fn
      @param {String}   type
      
      @return {kopi.db.models.Model}
      */


      kls.init = function(fn, type) {
        var cls;

        cls = this;
        cls.prepare().adapter(type).init(cls, fn);
        return cls;
      };

      /*
      Create model from attributes
      
      @param {Hash}     attrs
      @param {Function} fn
      @param {String}   type
      
      @return {kopi.db.models.Model}
      */


      kls.create = function(attrs, fn, type) {
        var cls, model;

        if (attrs == null) {
          attrs = {};
        }
        cls = this;
        model = new cls(attrs);
        model.save(fn, type);
        return cls;
      };

      /*
      Execute create query
      
      @param {Hash}     attrs
      @param {Function} fn
      @param {String}   type
      
      @return {kopi.db.models.Model}
      */


      kls._create = function(attrs, fn, type) {
        var cls;

        if (attrs == null) {
          attrs = {};
        }
        cls = this;
        new queries.CreateQuery(cls, attrs).execute(fn, type);
        return cls;
      };

      /*
      Define shortcut methods for model. e.g. Model.where({})
      */


      defineMethod = function(method) {
        return kls[method] = function() {
          var _ref;

          return (_ref = new queries.RetrieveQuery(this))[method].apply(_ref, arguments);
        };
      };

      _ref = queries.RetrieveQuery.ALL;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        method = _ref[_i];
        defineMethod(method);
      }

      /*
      
      @param {Hash}     criteria
      @param {Hash}     attrs
      @param {Function} fn
      @param {String}   type
      
      @return {kopi.db.models.Model}
      */


      kls._update = function(criteria, attrs, fn, type) {
        var cls;

        if (criteria == null) {
          criteria = {};
        }
        if (attrs == null) {
          attrs = {};
        }
        cls = this;
        new queries.UpdateQuery(cls, null, attrs).where(criteria).execute(fn, type);
        return cls;
      };

      /*
      
      @param {Hash}     criteria
      @param {Function} fn
      @param {String}   type
      @return {kopi.db.models.Model}
      */


      kls._destroy = function(criteria, fn, type) {
        var cls;

        if (criteria == null) {
          criteria = {};
        }
        cls = this;
        new queries.DestroyQuery(cls).where(criteria).execute(fn, type);
        return cls;
      };

      kls.raw = function() {
        var args, cls, fn, type, _j;

        args = 3 <= arguments.length ? __slice.call(arguments, 0, _j = arguments.length - 2) : (_j = 0, []), fn = arguments[_j++], type = arguments[_j++];
        cls = this;
        (function(func, args, ctor) {
          ctor.prototype = func.prototype;
          var child = new ctor, result = func.apply(child, args);
          return Object(result) === result ? result : child;
        })(queries.RawQuery, [cls].concat(__slice.call(args)), function(){}).execute(fn, type);
        return cls;
      };

      /*
      Model events
      */


      kls.BEFORE_FETCH_EVENT = "beforefetch";

      kls.AFTER_FETCH_EVENT = "afterfetch";

      kls.BEFORE_SAVE_EVENT = "beforesave";

      kls.AFTER_SAVE_EVENT = "aftersave";

      kls.BEFORE_CREATE_EVENT = "beforecreate";

      kls.AFTER_CREATE_EVENT = "aftercreate";

      kls.BEFORE_UPDATE_EVENT = "beforeupdate";

      kls.AFTER_UPDATE_EVENT = "afterupdate";

      kls.BEFORE_DESTROY_EVENT = "beforedestroy";

      kls.AFTER_DESTROY_EVENT = "afterdestroy";

      kls.VALUE_CHANGE_EVENT = "change";

      /*
      @param  {Hash}  attrs
      */


      function Model(attrs) {
        var cls, self;

        if (attrs == null) {
          attrs = {};
        }
        self = this;
        cls = this.constructor;
        cls.prefix || (cls.prefix = text.dasherize(cls.modelName()));
        if (!cls._prepared) {
          cls.prepare();
        }
        self._meta = cls.meta();
        self.guid = utils.guid(cls.prefix);
        self._new = true;
        self._type = cls.modelName();
        self._data = {};
        self._dirty = {};
        self._belongsTo = {};
        self._hasMany = {};
        self.isNew = true;
        self.update(attrs);
      }

      Model.prototype.pk = function() {
        return this[this._meta.pk];
      };

      Model.prototype.equals = function(model) {
        return this.pk() === model.pk();
      };

      Model.prototype.update = function(attrs) {
        var attribute, belongsTo, cls, hasMany, name, names, self;

        if (attrs == null) {
          attrs = {};
        }
        cls = this.constructor;
        self = this;
        names = this._meta.names;
        belongsTo = this._meta.belongsToNames;
        hasMany = this._meta.hasManyNames;
        for (name in attrs) {
          attribute = attrs[name];
          if (name in names || name in belongsTo || name in hasMany) {
            self[name] = attribute;
          }
        }
        return self;
      };

      /*
      Save model data
      
      @param {Function} fn    callback function
      @param {String}   type  adapter type
      @return {Model}         return self
      */


      Model.prototype.save = function(fn, type) {
        var attrs, cls, criteria, field, pk, pkName, self, thenFn, value, _ref1;

        cls = this.constructor;
        self = this;
        pk = self.pk();
        pkName = self._meta.pk;
        thenFn = function(error) {
          if (!error) {
            self.emit(self.isNew ? cls.AFTER_CREATE_EVENT : cls.AFTER_UPDATE_EVENT);
            self.emit(cls.AFTER_SAVE_EVENT);
            self.isNew = false;
          }
          if (fn) {
            return fn(error, self);
          }
        };
        self.emit(cls.BEFORE_SAVE_EVENT);
        if (!self.isNew) {
          criteria = {};
          criteria[pkName] = pk;
          attrs = {};
          _ref1 = self._dirty;
          for (field in _ref1) {
            value = _ref1[field];
            attrs[field] = self._data[field];
          }
          self.emit(cls.BEFORE_UPDATE_EVENT);
          cls._update(criteria, attrs, thenFn, type);
        } else {
          self.emit(cls.BEFORE_CREATE_EVENT);
          cls._create(object.clone(self._data), thenFn, type);
        }
        return self;
      };

      /*
      Remove model data from client
      
      @return {Model}
      */


      Model.prototype.destroy = function(fn, type) {
        var cls, criteria, self, thenFn;

        cls = this.constructor;
        self = this;
        criteria = {};
        criteria[self._meta.pk] = self.pk();
        thenFn = function(error) {
          if (!error) {
            self.emit(cls.AFTER_DESTROY_EVENT);
          }
          if (fn) {
            return fn(error, self);
          }
        };
        self.emit(cls.BEFORE_DESTROY_EVENT);
        cls._destroy(criteria, thenFn, type);
        return self;
      };

      Model.prototype.toString = function() {
        return "[" + (this.constructor.modelName()) + " " + (this.pk() || "null") + "]";
      };

      /*
      Return a copy of model's attributes
      */


      Model.prototype.toJSON = function() {
        return object.clone(this._data);
      };

      return Model;

    })(events.EventEmitter);
    return {
      INTEGER: INTEGER,
      STRING: STRING,
      TEXT: TEXT,
      FLOAT: FLOAT,
      DATETIME: DATETIME,
      JSON: JSON,
      Meta: Meta,
      Model: Model
    };
  });

}).call(this);
