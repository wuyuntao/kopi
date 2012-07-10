(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define("kopi/db/adapters/indexeddb", function(require, exports, module) {
    var IndexedDBAdapter, IndexedDBError, client, exceptions, logger, logging, models, queries, settings, support, win;
    exceptions = require("kopi/exceptions");
    logging = require("kopi/logging");
    settings = require("kopi/settings");
    support = require("kopi/utils/support");
    models = require("kopi/db/models");
    queries = require("kopi/db/queries");
    client = require("kopi/db/adapters/client");
    win = window;
    logger = logging.logger(module.id);
    IndexedDBError = (function(_super) {

      __extends(IndexedDBError, _super);

      function IndexedDBError(code, message) {
        this.code = code;
        this.message = message;
      }

      return IndexedDBError;

    })(exceptions.Exception);
    /*
      Adapter for IndexedDB
    */

    IndexedDBAdapter = (function(_super) {

      __extends(IndexedDBAdapter, _super);

      IndexedDBAdapter.support = function() {
        return !!support.indexedDB;
      };

      function IndexedDBAdapter(options) {
        var _base;
        IndexedDBAdapter.__super__.constructor.apply(this, arguments);
        (_base = this._options).version || (_base.version = "1");
      }

      /*
          Open a database and migrate to current version
      
          @param {String} name
      */


      IndexedDBAdapter.prototype.init = function(model, fn) {
        var request, self, version;
        self = this;
        if (self._db) {
          if (fn) {
            fn(null, self._db);
          }
          return self;
        }
        version = self._options.version;
        request = indexedDB.open(settings.kopi.db.indexedDB.name, version);
        request.onsuccess = function(e) {
          var db, setVersionRequest;
          db = self._db = request.result;
          if ((db.setVersion != null) && db.version !== version) {
            setVersionRequest = db.setVersion(version);
            setVersionRequest.onsuccess = function(e) {
              self.migrate(model);
              if (fn) {
                return fn(null, db);
              }
            };
            return setVersionRequest.onfailure = function(e) {
              var code, message;
              code = setVersionRequest.errorCode;
              message = support.prop("errorMessage", setVersionRequest);
              logger.error("Failed to set version for database. Error code: " + code + ". " + message);
              if (fn) {
                return fn(new IndexedDBError(code, message));
              }
            };
          } else {
            if (fn) {
              return fn(null, self._db);
            }
          }
        };
        request.onerror = function(e) {
          var code, message;
          self._db = null;
          code = request.errorCode;
          message = support.prop("errorMessage", request);
          logger.error("Failed to open database. Error code: " + code + ". " + message);
          if (fn) {
            return fn(new IndexedDBError(code, message));
          }
        };
        request.onupgradeneeded = function(e) {
          self._db = request.result;
          return self.migrate(model);
        };
        return self;
      };

      /*
      
      
          TODO Implement as an event
      */


      IndexedDBAdapter.prototype.migrate = function(model) {
        var index, meta, store, _i, _len, _ref, _results;
        meta = model.meta();
        store = this._db.createObjectStore(meta.dbName, {
          keyPath: meta.pk
        });
        _ref = meta.indexes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          index = _ref[_i];
          try {
            _results.push(store.createIndex(index, index));
          } catch (e) {
            _results.push(logger.error(e));
          }
        }
        return _results;
      };

      IndexedDBAdapter.prototype.create = function(query, fn) {
        var meta, request, self, store, value;
        self = this;
        meta = query.model.meta();
        store = self._store(meta.dbName, true);
        value = self._adapterObject(query.attrs(), meta.names);
        request = store.add(value);
        request.onsuccess = function(e) {
          if (fn) {
            fn(null, {
              pk: e.target.result[meta.pk]
            });
          }
        };
        request.onerror = function(e) {
          var code, message;
          code = request.errorCode;
          message = support.prop("errorMessage", request);
          logger.error("Failed to create object. Error code: " + code + ". " + message);
          if (fn) {
            fn(new IndexedDBError(code, message));
          }
        };
        return self;
      };

      IndexedDBAdapter.prototype.retrieve = function(query, fn) {
        var fields, isCount, limit, only, request, result, self, skip;
        self = this;
        fields = query.model.meta().names;
        isCount = query.count();
        only = query.only();
        limit = query.limit();
        skip = query.skip();
        result = isCount ? 0 : [];
        request = self._cursor(query);
        request.onsuccess = function(e) {
          var cursor, value;
          cursor = e.target.result;
          if (cursor) {
            if (skip > 0) {
              skip -= 1;
              cursor["continue"]();
              return;
            }
            if (limit && (isCount && result === limit) || (!isCount && result.length === limit)) {
              if (fn) {
                fn(null, result);
              }
              return;
            }
            if (isCount) {
              result += 1;
            } else {
              value = cursor.value;
              result.push(self._modelObject(value, fields));
            }
            return cursor["continue"]();
          } else {
            if (fn) {
              return fn(null, result);
            }
          }
        };
        request.onerror = function(e) {
          var code, message;
          code = request.errorCode;
          message = support.prop("errorMessage", request);
          logger.error("Failed to retrieve objects. Error code: " + code + ". " + message);
          if (fn) {
            return fn(new IndexedDBError(code, message));
          }
        };
        return self;
      };

      IndexedDBAdapter.prototype.update = function(query, fn) {
        var meta, request, self, store, value;
        self = this;
        meta = query.model.meta();
        store = self._store(meta.dbName, true);
        value = self._adapterObject(query.attrs(), meta.names);
        request = store.put(value);
        request.onsuccess = function(e) {
          if (fn) {
            return fn(null);
          }
        };
        request.onerror = function(e) {
          var code, message;
          code = request.errorCode;
          message = support.prop("errorMessage", request);
          logger.error("Failed to update objects. Error code: " + code + ". " + message);
          if (fn) {
            return fn(new IndexedDBError(code, message));
          }
        };
        return self;
      };

      IndexedDBAdapter.prototype.destroy = function(query, fn) {
        var request, self, store;
        self = this;
        store = self._store(query.model.dbName(), true);
        request = store["delete"](query.pk());
        request.onsuccess = function(e) {
          if (fn) {
            return fn(null);
          }
        };
        request.onerror = function(e) {
          var code, message;
          code = request.errorCode;
          message = support.prop("errorMessage", request);
          logger.error("Failed to destroy objects. Error code: " + code + ". " + message);
          if (fn) {
            return fn(new IndexedDBError(code, message));
          }
        };
        return self;
      };

      /*
          Create transaction and return object store
      */


      IndexedDBAdapter.prototype._store = function(storeName, write, fn) {
        var transaction;
        if (write == null) {
          write = false;
        }
        transaction = this._db.transaction(storeName, write ? IDBTransaction.READ_WRITE : IDBTransaction.READ_ONLY);
        transaction.oncomplete = function(e) {
          if (fn) {
            return fn(null);
          }
        };
        transaction.onerror = function(e) {
          var code, message;
          code = transaction.errorCode;
          message = support.prop("errorMessage", transaction);
          if (fn) {
            return fn(new IndexedDBError(code, message));
          }
        };
        return transaction.objectStore(storeName);
      };

      /*
          Create object store cursor for query
      
          Limitations:
            1. IndexedDB only supports one field querying, if where condition has multiple
               fields, it will raise an exception
            2. IndexedDB only supports following condition filters:
               lt, lte, gt, gte, eq, ne
      
          TODO Extend multi-field querying and extra filters in JavaScript side?
      */


      IndexedDBAdapter.prototype._cursor = function(query) {
        var ascending, condition, context, direction, field, fields, index, keyRange, meta, openCursor, pk, queryKey, self, sortKey, store, _ref, _ref1;
        self = this;
        meta = query.model.meta();
        fields = meta.names;
        pk = meta.pk;
        store = self._store(meta.dbName);
        openCursor = null;
        queryKey = null;
        _ref = query.where();
        for (field in _ref) {
          condition = _ref[field];
          if (queryKey != null) {
            throw new queries.QueryError("IndexedDB does not support multi-field querying.");
          }
          if (field === pk) {
            queryKey = field;
            context = store;
            keyRange = self._keyRange(condition, fields[field]);
            break;
          } else if (__indexOf.call(meta.indexes, field) >= 0) {
            queryKey = field;
            index = store.index(field);
            context = index;
            keyRange = self._keyRange(condition, fields[field]);
          }
        }
        if (!(queryKey != null)) {
          queryKey = pk;
          context = store;
          keyRange = null;
        }
        sortKey = null;
        direction = IDBCursor.NEXT;
        _ref1 = query.sort();
        for (field in _ref1) {
          ascending = _ref1[field];
          if ((sortKey != null) || field !== queryKey) {
            throw new queries.QueryError("IndexedDB does not support multi-field sorting.");
          }
          sortKey = field;
          if (!ascending) {
            direction = IDBCursor.PREV;
          }
        }
        return context.openCursor(keyRange, direction);
      };

      IndexedDBAdapter.prototype._keyRange = function(condition, field) {
        var lowerBound, self, upperBound, value;
        self = this;
        value = function(op) {
          return self._adapterValue(condition[op], field);
        };
        if (queries.EQ in condition) {
          return IDBKeyRange.only(value(queries.EQ));
        } else {
          lowerBound = null;
          upperBound = null;
          if (queries.LT in condition) {
            upperBound = [value(queries.LT), true];
          } else if (queries.LTE in condition) {
            upperBound = [value(queries.LTE), false];
          }
          if (queries.GT in condition) {
            lowerBound = [value(queries.GT), true];
          } else if (queries.GTE in condition) {
            lowerBound = [value(queries.GTE), false];
          }
          if (lowerBound && !upperBound) {
            return IDBKeyRange.lowerBound.apply(IDBKeyRange, lowerBound);
          } else if (upperBound && !lowerBound) {
            return IDBKeyRange.upperBound.apply(IDBKeyRange, upperBound);
          } else if (lowerBound && upperBound) {
            return IDBKeyRange.bound(lowerBound[0], upperBound[0], lowerBound[1], upperBound[1]);
          }
        }
        return null;
      };

      IndexedDBAdapter.prototype._adapterValue = function(value, field) {
        var self;
        self = this;
        switch (field.type) {
          case models.DATETIME:
            return value.getTime();
          case models.JSON:
            return self._adapterObject(value);
          default:
            return IndexedDBAdapter.__super__._adapterValue.apply(this, arguments);
        }
      };

      IndexedDBAdapter.prototype._modelValue = function(value, field) {
        var self;
        self = this;
        switch (field.type) {
          case models.DATETIME:
            return new Date(value);
          case models.JSON:
            return self._modelObject(value);
          default:
            return IndexedDBAdapter.__super__._modelValue.apply(this, arguments);
        }
      };

      return IndexedDBAdapter;

    })(client.ClientAdapter);
    return {
      IndexedDBAdapter: IndexedDBAdapter
    };
  });

}).call(this);
