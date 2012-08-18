(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/tests/app", function(require, exports, module) {
    var $, AlphaView, BetaView, DeltaApp, GammaView, app, base, hist, loc, q, router, uri, views, win;
    $ = require("jquery");
    q = require("qunit");
    base = require("kopi/tests/base");
    views = require("kopi/views");
    app = require("kopi/app");
    router = require("kopi/app/router");
    uri = require("kopi/utils/uri");
    loc = location;
    hist = history;
    win = $(window);
    base = uri.current();
    AlphaView = (function(_super) {

      __extends(AlphaView, _super);

      function AlphaView() {
        return AlphaView.__super__.constructor.apply(this, arguments);
      }

      return AlphaView;

    })(views.View);
    BetaView = (function(_super) {

      __extends(BetaView, _super);

      function BetaView() {
        return BetaView.__super__.constructor.apply(this, arguments);
      }

      return BetaView;

    })(views.View);
    GammaView = (function(_super) {

      __extends(GammaView, _super);

      function GammaView() {
        return GammaView.__super__.constructor.apply(this, arguments);
      }

      return GammaView;

    })(views.View);
    DeltaApp = (function(_super) {

      __extends(DeltaApp, _super);

      function DeltaApp() {
        return DeltaApp.__super__.constructor.apply(this, arguments);
      }

      return DeltaApp;

    })(app.App);
    router.view(AlphaView).route('/alpha', {
      name: 'alpha-list'
    }).route('/alpha/:id', {
      name: 'alpha-detail'
    }).end().view(BetaView).route('/beta', {
      name: 'beta-list',
      group: true
    }).route('/beta/:id', {
      name: 'beta-detail',
      group: true
    }).end().view(GammaView).route('/gamma/:id/page', {
      name: 'gamma-page-list',
      group: "id"
    }).route('/gamma/:id/page/:page', {
      name: 'gamma-page-detail',
      group: ["id"]
    }).end();
    return $(function() {
      app = new DeltaApp();
      app.start();
      q.module("kopi/app");
      q.test("push state", function() {
        var waitFn;
        app.configure({
          usePushState: true,
          useHashChange: false,
          useInterval: false,
          alwaysUseHash: false
        });
        q.stop();
        app.once(DeltaApp.REQUEST_EVENT, function(e, url) {
          q.equal(url.path, "/alpha");
          return q.start();
        });
        app.load("/alpha");
        app.currentURL = "/alpha";
        q.equal(loc.pathname, "/alpha");
        q.stop();
        app.once(DeltaApp.REQUEST_EVENT, function(e, url) {
          q.equal(url.path, "/alpha/1");
          return q.start();
        });
        app.load("/alpha/1");
        app.currentURL = "/alpha/1";
        q.equal(loc.pathname, "/alpha/1");
        q.stop();
        app.once(DeltaApp.REQUEST_EVENT, function(e, url) {
          q.equal(url.path, "/alpha");
          return q.start();
        });
        hist.back();
        q.stop();
        waitFn = function() {
          app.currentURL = "/alpha";
          q.equal(loc.pathname, "/alpha");
          q.start();
          return hist.pushState(null, null, base);
        };
        return setTimeout(waitFn, 500);
      });
      q.test("push state with hash", function() {
        var waitFn;
        app.configure({
          usePushState: true,
          useHashChange: false,
          useInterval: false,
          alwaysUseHash: true
        });
        q.stop();
        app.once(DeltaApp.REQUEST_EVENT, function(e, url) {
          q.equal(url.path, "/alpha");
          return q.start();
        });
        app.load("/alpha");
        app.currentURL = "/alpha";
        q.equal(loc.hash, "#../alpha");
        q.stop();
        app.once(DeltaApp.REQUEST_EVENT, function(e, url) {
          q.equal(url.path, "/alpha/1");
          return q.start();
        });
        app.load("/alpha/1");
        app.currentURL = "/alpha/1";
        q.equal(loc.hash, "#../alpha/1");
        q.stop();
        app.once(DeltaApp.REQUEST_EVENT, function(e, url) {
          q.equal(url.path, "/alpha");
          return q.start();
        });
        hist.back();
        q.stop();
        waitFn = function() {
          app.currentURL = "/alpha";
          q.equal(loc.hash, "#../alpha");
          q.start();
          return hist.pushState(null, null, base);
        };
        return setTimeout(waitFn, 500);
      });
      return q.test("hash change", function() {
        var waitFn;
        app.configure({
          usePushState: false,
          useHashChange: true,
          useInterval: false,
          alwaysUseHash: true
        });
        app.load("/alpha");
        app.currentURL = "/alpha";
        q.equal(loc.hash, "#../alpha");
        app.load("/alpha/1");
        app.currentURL = "/alpha/1";
        q.equal(loc.hash, "#../alpha/1");
        hist.back();
        q.stop();
        waitFn = function() {
          app.currentURL = "/alpha";
          q.equal(loc.hash, "#../alpha");
          q.start();
          return hist.pushState(null, null, base);
        };
        return setTimeout(waitFn, 500);
      });
    });
  });

}).call(this);
