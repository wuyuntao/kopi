(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/app", function(require, exports, module) {
    var $, App, Viewport, array, baseURL, events, hist, klass, loc, logger, logging, overlays, settings, support, text, uri, utils, win;
    $ = require("jquery");
    settings = require("kopi/settings");
    logging = require("kopi/logging");
    events = require("kopi/events");
    utils = require("kopi/utils");
    uri = require("kopi/utils/uri");
    support = require("kopi/utils/support");
    text = require("kopi/utils/text");
    array = require("kopi/utils/array");
    klass = require("kopi/utils/klass");
    Viewport = require("kopi/ui/viewport").Viewport;
    overlays = require("kopi/ui/notification/overlays");
    win = $(window);
    hist = history;
    loc = location;
    baseURL = uri.current();
    logger = logging.logger(module.id);
    /*
    Application class
    
    Usage
    
    class BookApp extends App
    
      onstart: ->
        super
        # Do stuff when app starts
        self = this
        self.bookNavBar = new BookNavBar()
        self.bookViewer = new BookViewer()
        self.taskQueue = new TaskQueue()
        self.taskWorker = new TaskWorker(self.taskQueue)
    
      onrequest: (e, url) ->
        if url.match(/^\/books$/)
          # Do stuff when url matches /books
        else if url.match(/^\/books/\d+$/)
          # Do stuff when url matches /books/1
        super
    
    $ ->
      new BookApp().start()
    */

    App = (function(_super) {

      __extends(App, _super);

      App.START_EVENT = "start";

      App.REQUEST_EVENT = "request";

      App.VIEW_LOAD_EVENT = "viewload";

      App.LOCK_EVENT = "lock";

      App.UNLOCK_EVENT = "unlock";

      klass.singleton(App);

      klass.configure(App);

      klass.accessor(App.prototype, "router");

      function App(options) {
        var self;
        if (options == null) {
          options = {};
        }
        this._isSingleton();
        self = this;
        self.guid = utils.guid("app");
        self.started = false;
        self.locked = false;
        self.currentURL = null;
        self.currentView = null;
        self._views = {};
        self._interval = null;
        self._router = null;
        self.viewport = new Viewport();
        self.configure(settings.kopi.app, options);
      }

      App.prototype.lock = function() {
        var cls, self;
        self = this;
        if (self.locked) {
          return self;
        }
        cls = this.constructor;
        overlays.show({
          transparent: true
        });
        return self.emit(cls.LOCK_EVENT);
      };

      App.prototype.unlock = function() {
        var cls, self;
        self = this;
        if (!self.locked) {
          return self;
        }
        cls = this.constructor;
        overlays.hide();
        return self.emit(cls.UNLOCK_EVENT);
      };

      App.prototype.onlock = function() {
        return this.locked = true;
      };

      App.prototype.onunlock = function() {
        return this.locked = false;
      };

      /*
      Launch the application
      */


      App.prototype.start = function() {
        var cls, self;
        cls = this.constructor;
        self = this;
        if (self.started) {
          logger.warn("[app:start] App has already been launched.");
          return self;
        }
        self.container = $("body");
        self.viewport.skeleton().render();
        self._listenToURLChange();
        self.emit(cls.START_EVENT);
        logger.info("[app:start] Start app: " + self.guid);
        self.started = true;
        if (!(support.history && self._options.usePushState)) {
          self.load(self._options.startURL || self.getCurrentURL());
        }
        return self;
      };

      App.prototype.stop = function() {
        var self;
        self = this;
        self._stopListenToURLChange();
        self.started = false;
        self.viewport.destroy();
        return self;
      };

      App.prototype.getCurrentURL = function() {
        var url;
        url = uri.parse(location.href);
        return uri.absolute((url.fragment ? url.fragment.substr(1) : ""), url.urlNoQuery);
      };

      /*
      load URL
      
      @param {String} url   URL must be an absolute path without query string and fragment
      @param {Hash} options
      */


      App.prototype.load = function(url, options) {
        var cls, self, state;
        logger.info("[app:load] Load URL: " + url);
        cls = this.constructor;
        self = this;
        url = uri.parse(uri.absolute(url));
        if (support.history && self._options.usePushState) {
          if (self._options.alwaysUseHash) {
            state = "#" + uri.relative(url.urlNoQuery, baseURL);
          } else {
            state = url.path;
          }
          self.once(cls.VIEW_LOAD_EVENT, function() {
            return hist.pushState(null, null, state);
          });
        } else if (self._options.useHashChange || self._options.useInterval) {
          self.once(cls.VIEW_LOAD_EVENT, function() {
            return loc.hash = uri.relative(url.urlNoQuery, baseURL);
          });
        }
        self.emit(cls.REQUEST_EVENT, [url, options]);
        return self;
      };

      /*
      callback when app receives new request
      
      @param {Event}  e
      @param {kopi.utils.uri.URI} url
      */


      App.prototype.onrequest = function(e, url, options) {
        var cls, isUpdate, match, request, self, view;
        logger.info("[app:onrequest] Receive request: " + url.path);
        self = this;
        cls = this.constructor;
        match = self._match(url);
        if (!match) {
          logger.info("[app:onrequest] No matching view found.");
          if (self._options.redirectWhenNoRouteFound) {
            url = uri.unparse(url);
            logger.info("[app:onrequest] Redirect to URL: " + url);
            uri.redirect(url);
          }
          return;
        }
        view = match[0], request = match[1];
        isUpdate = false;
        if (self.currentView && self.currentView.equals(view)) {
          isUpdate = true;
          self.currentView.update(request.url, request.params, options);
          return;
        }
        if (!view.created) {
          view.create();
        }
        view.start(request.url, request.params, options);
        if (!isUpdate && self.currentView && self.currentView.started) {
          self.currentView.stop(options);
        }
        self.currentView = view;
        self.currentURL = url;
        return self.emit(cls.VIEW_LOAD_EVENT);
      };

      /*
      Listen to URL change events.
      For HTML5 browsers, listen to `onpopstate` event by default.
      For HTML4 browsers, listen to `onhashchange` event by default.
      For Legacy browsers, check url change by interval.
      */


      App.prototype._listenToURLChange = function() {
        var checkFn, self;
        self = this;
        checkFn = function() {
          return self._checkURLChange();
        };
        if (support.history && self._options.usePushState) {
          self._useHash = self._options.alwaysUseHash;
          win.bind('popstate', checkFn);
        } else if (support.hash && (self._options.usePushState || self._options.useHashChange)) {
          self._useHash = true;
          win.bind("hashchange", checkFn);
        } else if (self._options.useInterval) {
          self._useHash = true;
          self._interval = setInterval(checkFn, self._options.interval);
        } else {
          logger.warn("[app:_listenToURLChange] App will not repond to url change");
        }
      };

      /*
      Listen to URL change events.
      For HTML5 browsers, stop listen to `onpopstate` event by default.
      For HTML4 browsers, stop listen listen to `onhashchange` event by default.
      For Legacy browsers, stop listen check url change by interval.
      */


      App.prototype._stopListenToURLChange = function() {
        var self;
        self = this;
        if (support.history && self._options.usePushState) {
          win.unbind('popstate');
        } else if (support.hash && self._options.useHashChange) {
          win.unbind("hashchange");
        } else if (self._options.useInterval) {
          if (self._interval) {
            clearInterval(self._interval);
            self._interval = null;
          }
        }
      };

      /*
      Check if URL is different from last state
      */


      App.prototype._checkURLChange = function() {
        var cls, self, url;
        cls = this.constructor;
        self = this;
        url = uri.parse(location.href);
        if (self._useHash) {
          url.path = uri.absolute(url.fragment.replace(/^#/, ''), url.path);
        }
        if (!self.currentURL || url.path !== self.currentURL.path) {
          self.currentURL = url;
          self.emit(cls.REQUEST_EVENT, [url]);
        }
        return self;
      };

      /*
      Find existing view in stack
      
      @param  {kopi.utils.uri.URI} url
      @return {kopi.views.View}
      */


      App.prototype._match = function(url) {
        var guid, matches, param, path, request, route, self, view, _i, _len, _ref, _ref1;
        if (!this._router) {
          return logger.warn("[app:_match] Router is not provided");
        }
        self = this;
        path = uri.parse(url).path;
        request = this._router.match(path);
        if (!request) {
          return logger.warn("[app:_match] Can not find proper route for path: " + path);
        }
        route = request.route;
        _ref = self._views;
        for (guid in _ref) {
          view = _ref[guid];
          if (route.group === true && view.constructor.viewName() === route.view.viewName()) {
            logger.log("[app:_match] group: true");
            return [view, request];
          } else if (text.isString(route.group)) {
            if (view.params[route.group] === route.params[route.group]) {
              return [view, request];
            }
          } else if (array.isArray(route.group)) {
            matches = true;
            _ref1 = route.group;
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              param = _ref1[_i];
              if (view.params[param] !== route.params[param]) {
                matches = false;
                break;
              }
            }
            if (matches) {
              return [view, request];
            }
          } else {
            if (view.url.path === path) {
              return [view, request];
            }
          }
        }
        view = new route.view(self, request.url, request.params);
        self._views[view.guid] = view;
        return [view, request];
      };

      return App;

    })(events.EventEmitter);
    return {
      App: App,
      instance: function() {
        return App.instance();
      }
    };
  });

}).call(this);
