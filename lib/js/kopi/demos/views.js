(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/demos/views", function(require, exports, module) {
    var IndexView, NavList, NavListItem, Text, navigation, settings, views, viewswitchers;

    views = require("kopi/views");
    NavList = require("kopi/ui/lists").NavList;
    NavListItem = require("kopi/ui/lists/items").NavListItem;
    navigation = require("kopi/ui/navigation");
    viewswitchers = require("kopi/ui/viewswitchers");
    settings = require("kopi/demos/settings");
    Text = require("kopi/ui/text").Text;
    IndexView = (function(_super) {
      __extends(IndexView, _super);

      function IndexView() {
        IndexView.__super__.constructor.apply(this, arguments);
        this.nav = new navigation.Nav({
          title: "Index"
        });
        this.view = new viewswitchers.View();
        this.list = new NavList();
      }

      IndexView.prototype.oncreate = function() {
        var categories, category, _i, _len;

        this.app.navbar.add(this.nav);
        this.nav.skeleton();
        this.app.viewSwitcher.add(this.view);
        this.view.skeleton();
        categories = [["App", "/app/"], ["Model", "/model/"], ["View", "/view/"], ["UI", "/ui/"]];
        for (_i = 0, _len = categories.length; _i < _len; _i++) {
          category = categories[_i];
          this.list.add(new NavListItem(this.list, category));
        }
        this.list.skeletonTo(this.view.element);
        return IndexView.__super__.oncreate.apply(this, arguments);
      };

      IndexView.prototype.onstart = function() {
        this.app.navbar.show(this.nav);
        this.app.viewSwitcher.show(this.view);
        this.nav.render();
        this.view.render();
        this.list.render();
        return IndexView.__super__.onstart.apply(this, arguments);
      };

      IndexView.prototype.ondestroy = function() {
        this.nav.destroy();
        this.view.destroy();
        this.list.destroy();
        return IndexView.__super__.ondestroy.apply(this, arguments);
      };

      return IndexView;

    })(views.View);
    return {
      IndexView: IndexView
    };
  });

}).call(this);
