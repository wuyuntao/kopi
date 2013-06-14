(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/demos/views/uilists", function(require, exports, module) {
    var List, ListItem, Scrollable, UIListView, View, navigation, reverse, viewswitchers;

    View = require("kopi/views").View;
    navigation = require("kopi/ui/navigation");
    viewswitchers = require("kopi/ui/viewswitchers");
    reverse = require("kopi/app/router").reverse;
    Scrollable = require("kopi/ui/scrollable").Scrollable;
    List = require("kopi/ui/lists").List;
    ListItem = require("kopi/ui/lists/items").ListItem;
    UIListView = (function(_super) {
      __extends(UIListView, _super);

      function UIListView() {
        var backButton;

        UIListView.__super__.constructor.apply(this, arguments);
        backButton = new navigation.NavButton({
          url: reverse("ui"),
          titleText: "Back"
        });
        this.nav = new navigation.Nav({
          title: "List",
          leftButton: backButton
        });
        this.view = new viewswitchers.View();
        this.scrollable = new Scrollable({
          scrollX: false
        });
        this.list = new List({
          striped: true
        });
      }

      UIListView.prototype.oncreate = function() {
        var i, _i;

        this.app.navbar.add(this.nav);
        this.nav.skeleton();
        this.app.viewSwitcher.add(this.view);
        this.view.skeleton();
        this.scrollable.skeletonTo(this.view.element);
        for (i = _i = 1; _i <= 30; i = ++_i) {
          this.list.add(new ListItem(this.list, "List Item " + i));
        }
        this.list.skeletonTo(this.scrollable.container());
        return UIListView.__super__.oncreate.apply(this, arguments);
      };

      UIListView.prototype.onstart = function() {
        this.app.navbar.show(this.nav);
        this.app.viewSwitcher.show(this.view);
        this.nav.render();
        this.view.render();
        this.list.render();
        this.scrollable.render();
        return UIListView.__super__.onstart.apply(this, arguments);
      };

      UIListView.prototype.ondestroy = function() {
        this.scrollable.destroy();
        this.list.destroy();
        this.nav.destroy();
        this.view.destroy();
        return UIListView.__super__.ondestroy.apply(this, arguments);
      };

      return UIListView;

    })(View);
    return {
      UIListView: UIListView
    };
  });

}).call(this);
