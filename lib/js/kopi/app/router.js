(function() {

  define("kopi/app/router", function(require, exports, module) {
    var Router, instance, match, object, reverse, router, uri, view;
    object = require("kopi/utils/object");
    uri = require("kopi/utils/uri");
    /*
      URL routing manager
    */

    Router = (function() {

      function Router() {
        var self;
        self = this;
        self.routes = [];
        self.statics = {};
        self.dynamics = [];
        self.names = {};
        self.views = [];
        self.compiled = false;
        self.syntax = /:([a-zA-Z_]+)?(?:#(.*?)#)?/i;
        self.base = '[^/]+';
      }

      /*
          Add a route.
          The route string may contain `:key`, `:key#regexp#` or `:#regexp#` tokens
          for each dynamic part of the route. These can be escaped with a backslash
          in front of the `:` and are completely ignored if static is true.
      
          @param {Object} option
          @option {String} name
          @option {Boolean|String|Array} group
            If `group` is `true`, use same view for every URL matches route
            If `group` is `false`, use unique view for every different URL
            If `group` is String or Array, views are grouped by specific arguments
      */


      Router.prototype.add = function(route, view, option) {
        var self;
        if (option == null) {
          option = {};
        }
        self = this;
        route = {
          route: route.replace('\\:', ':'),
          realroute: route,
          view: view,
          tokens: route.split(this.syntax),
          name: option.name,
          group: option.group
        };
        if (!self.exists(route)) {
          self.routes.push(route);
          self.compiled = false;
        }
        return self;
      };

      Router.prototype.exists = function(route) {
        var exist, _i, _len, _ref;
        _ref = this.routes;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          exist = _ref[_i];
          if (route.realroute === exist.realroute) {
            return true;
          }
        }
        return false;
      };

      Router.prototype.group = function(route) {
        var i, out, params, part, _i, _len, _ref;
        out = '';
        params = [];
        _ref = route.tokens;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          part = _ref[i];
          if (i % 3 === 0) {
            out += part.replace('\:', ':').replace('(', '\\(').replace(')', '\\)');
          } else if (i % 3 === 1) {
            params.push(part || params.length);
            out += '(';
          } else {
            out += (part || this.base) + ')';
          }
        }
        return [out, params];
      };

      Router.prototype.isStatic = function(route) {
        return route.tokens.length === 1;
      };

      Router.prototype.match = function(path) {
        var dynamic, i, matches, param, params, route, self, url, _i, _j, _len, _len1, _ref, _ref1;
        self = this;
        url = uri.parse(path);
        if (url.path in self.statics) {
          route = self.statics[url.path];
          return {
            route: route,
            url: url,
            params: {}
          };
        }
        _ref = self.dynamics;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          dynamic = _ref[_i];
          matches = url.path.match(dynamic.regexp);
          if (matches) {
            route = dynamic.route;
            params = {};
            _ref1 = dynamic.params;
            for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
              param = _ref1[i];
              params[param] = matches[i + 1];
            }
            return {
              route: route,
              url: url,
              params: params
            };
          }
        }
        if (!self.compiled) {
          self.compile();
          return self.match(path);
        }
      };

      Router.prototype.compile = function() {
        var i, params, regexp, route, self, _i, _len, _ref, _ref1;
        self = this;
        self.reset();
        _ref = self.routes;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          route = _ref[i];
          if (route.name) {
            self.names[route.name] = route;
          }
          if (self.isStatic(route)) {
            self.statics[route.route] = route;
            continue;
          }
          _ref1 = self.group(route), regexp = _ref1[0], params = _ref1[1];
          route.params = params;
          self.dynamics.push({
            regexp: new RegExp('^' + regexp + '$', 'i'),
            params: params,
            route: route
          });
        }
        self.dynamics.reverse();
        self.compiled = true;
        return self;
      };

      Router.prototype.build = function(route, params) {
        if (this.isStatic(route)) {
          return route.route;
        }
      };

      Router.prototype.reset = function() {
        var self;
        self = this;
        self.compiled = false;
        self.statics = {};
        self.dynamics = [];
        self.names = {};
        self.views = {};
        return self;
      };

      return Router;

    })();
    router = new Router();
    instance = function() {
      return router;
    };
    match = function() {
      return router.match.apply(router, arguments);
    };
    /*
      Build route by given name
    */

    reverse = function(name, params) {
      var route;
      route = router.names[name];
      if (route) {
        return router.build(route, params);
      }
    };
    /*
      Return a view object to add route
    
      Usage:
    
        router
          .view(BookListView)
            .route("/book", name: "book-list")
            .route("/book/search", name: "book-search")
            .route("/book/:category, name: "book-category", group: "category")
            .end()
          .view(BookDetailView)
            .route("/book/:id", name: "book-detail", group: "id")
            .route("/book/:id/chapter", name: "chapter-list", group: "id")
            .end()
          .view(ChapterDetailView)
            .route("/book/:bid/chapter/:chid", name: "chapter-detail", group: ["bid", "chid"])
            .end()
          ...
    */

    view = function(view) {
      return {
        route: function(route, option) {
          router.add(route, view, option);
          return this;
        },
        end: function() {
          return module.exports;
        }
      };
    };
    return {
      instance: instance,
      match: match,
      reverse: reverse,
      view: view
    };
  });

}).call(this);
