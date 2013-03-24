(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/views", function(require, exports, module) {
    var View, events, exceptions, func, html, klass, logger, logging, settings, text, utils;
    exceptions = require("kopi/exceptions");
    klass = require("kopi/utils/klass");
    settings = require("kopi/settings");
    events = require("kopi/events");
    logging = require("kopi/logging");
    utils = require("kopi/utils");
    html = require("kopi/utils/html");
    text = require("kopi/utils/text");
    func = require("kopi/utils/func");
    logger = logging.logger(module.id);
    /*
      Base class of views
    
      Life cycle of a view:
    
      Constructor -> Create -> Start (-> Update) -> Stop -> Destroy (-> Create -> ...)
    
    
      Example:
    
        class SomeView
    
          oncreate: ->
            this.nav = new SomeNav()
            this.content = new SomeContent()
            this.footer = new SomeTabs()
    
          onstart: ->
            this.nav.skeleton().render()
            this.content.skeleton().render()
            this.footer.skeleton().render()
    
            this.app.navBar.load(this.nav)
            this.app.viewFlipper.load(this.content)
            this.app.tabBar.load(this.footer)
    
          onstop: ->
            this.nav.destroy()
            this.content.destroy()
            this.footer.destroy()
    
          ondestroy: ->
            this.nav = null
            this.content = null
            this.footer = null
    */

    View = (function(_super) {
      var kls;

      __extends(View, _super);

      kls = View;

      kls.CREATE_EVENT = "create";

      kls.START_EVENT = "start";

      kls.UPDATE_EVENT = "update";

      kls.STOP_EVENT = "stop";

      kls.DESTROY_EVENT = "destroy";

      kls.LOCK_EVENT = "lock";

      kls.UNLOCK_EVENT = "unlock";

      klass.accessor(kls, "viewName", {
        get: function() {
          return this._viewName || (this._viewName = this.name);
        }
      });

      View.viewName("View");

      function View(app, url, params) {
        var self, _base;
        if (params == null) {
          params = {};
        }
        if (!app) {
          throw new exceptions.ValueError("app must be instance of Application");
        }
        self = this;
        (_base = self.constructor).prefix || (_base.prefix = text.dasherize(self.constructor.viewName()));
        self.guid = utils.guid(self.constructor.prefix);
        self.app = app;
        self.url = url;
        self.params = params;
        self.created = false;
        self.started = false;
        self.locked = false;
      }

      /*
          Initialize UI components skeleton and append them to DOM Tree
      */


      View.prototype.create = function(options) {
        var cls, self;
        cls = this.constructor;
        self = this;
        if (self.created || self.locked) {
          logger.warn("View is already created or locked.");
          return self;
        }
        logger.info("Create view. " + self.guid);
        self.lock();
        self.emit(cls.CREATE_EVENT, [options]);
        self.created = true;
        return self.unlock();
      };

      /*
          Display UI components and then render them with data
      */


      View.prototype.start = function(url, params, options) {
        var cls, self;
        cls = this.constructor;
        self = this;
        if (!self.created) {
          throw new exceptions.ValueError("Must create view first.");
        }
        if (self.started || self.locked) {
          logger.warn("View is already started or locked.");
          return self;
        }
        logger.info("Start view. " + self.guid);
        self.lock();
        self.emit(cls.START_EVENT, [url, params, options]);
        self.started = true;
        return self.unlock();
      };

      /*
          Update UI components when URL changes
      */


      View.prototype.update = function(url, params, options) {
        var cls, self;
        cls = this.constructor;
        self = this;
        if (!self.started) {
          logger.error("Must start view first.");
          return self;
        }
        if (self.locked) {
          logger.warn("View is locked.");
          return self;
        }
        logger.info("Update view. " + self.guid);
        return self.emit(cls.UPDATE_EVENT, [url, params, options]);
      };

      /*
          Hide UI components
      */


      View.prototype.stop = function(options) {
        var cls, self;
        cls = this.constructor;
        self = this;
        if (!self.created) {
          throw new exceptions.ValueError("Must create view first.");
        }
        if (!self.started || self.locked) {
          logger.warn("View is already stopped or locked.");
          return self;
        }
        logger.info("Stop view. " + self.guid);
        self.lock();
        self.emit(cls.STOP_EVENT, [options]);
        self.started = false;
        return self.unlock();
      };

      /*
          Remove UI components from DOM Tree
      */


      View.prototype.destroy = function(options) {
        var cls, self;
        cls = this.constructor;
        self = this;
        if (self.started) {
          throw new exceptions.ValueError("Must stop view first.");
        }
        if (!self.created || self.locked) {
          logger.warn("View is already destroyed or locked.");
          return self;
        }
        logger.info("Destroy view. " + self.guid);
        self.lock();
        self.emit(cls.DESTROY_EVENT, [options]);
        self.created = false;
        return self.unlock();
      };

      View.prototype.lock = function() {
        var cls, self;
        cls = this.constructor;
        self = this;
        if (self.locked) {
          return self;
        }
        logger.info("Lock view. " + self.guid);
        self.locked = true;
        self.emit(cls.LOCK_EVENT);
        return self;
      };

      View.prototype.unlock = function() {
        var cls, self;
        cls = this.constructor;
        self = this;
        if (!self.locked) {
          return self;
        }
        logger.info("Unlock view. " + self.guid);
        self.locked = false;
        self.emit(cls.UNLOCK_EVENT);
        return self;
      };

      /*
          Template methods of view events
      */


      View.prototype.oncreate = function(e) {};

      View.prototype.onstart = function(e) {};

      View.prototype.onupdate = function(e) {};

      View.prototype.onstop = function(e) {};

      View.prototype.ondestroy = function(e) {};

      View.prototype.onlock = function(e) {};

      View.prototype.onunlock = function(e) {};

      /*
          Helper methods
      */


      View.prototype.equals = function(view) {
        return this.guid === view.guid;
      };

      return View;

    })(events.EventEmitter);
    return {
      View: View
    };
  });

}).call(this);
