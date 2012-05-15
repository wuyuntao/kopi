// Generated by CoffeeScript 1.3.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  define("kopi/demos/views", function(require, exports, module) {
    var IndexView, Text, adapters, lists, navigation, settings, views, viewswitchers;
    views = require("kopi/views");
    lists = require("kopi/ui/lists");
    adapters = require("kopi/ui/groups/adapters");
    navigation = require("kopi/ui/navigation");
    viewswitchers = require("kopi/ui/viewswitchers");
    settings = require("kopi/demos/settings");
    Text = require("kopi/ui/text").Text;
    IndexView = (function(_super) {

      __extends(IndexView, _super);

      IndexView.name = 'IndexView';

      function IndexView() {
        IndexView.__super__.constructor.apply(this, arguments);
        this.nav = new navigation.Nav({
          title: "Index"
        });
        this.view = new viewswitchers.View();
        this.list = new lists.NavList();
      }

      IndexView.prototype.oncreate = function() {
        var self;
        self = this;
        self.app.navBar.add(self.nav);
        self.nav.skeleton();
        self.app.viewSwitcher.add(self.view);
        self.view.skeleton();
        self.list.adapter(new adapters.ArrayAdapter([["App", "/app/"], ["Model", "/model/"], ["View", "/view/"], ["UI", "/ui/"]])).skeletonTo(self.view.element);
        return IndexView.__super__.oncreate.apply(this, arguments);
      };

      IndexView.prototype.onstart = function() {
        var self;
        self = this;
        self.app.navBar.show(self.nav);
        self.app.viewSwitcher.show(self.view);
        self.nav.render();
        self.view.render();
        self.list.render();
        return IndexView.__super__.onstart.apply(this, arguments);
      };

      IndexView.prototype.ondestroy = function() {
        self.nav.destroy();
        self.view.destroy();
        self.list.destroy();
        return IndexView.__super__.ondestroy.apply(this, arguments);
      };

      return IndexView;

    })(views.View);
    return {
      IndexView: IndexView
    };
  });

}).call(this);
