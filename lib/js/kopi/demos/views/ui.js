(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/demos/views/ui", function(require, exports, module) {
    var NavList, NavListItem, UIView, View, navigation, reverse, viewswitchers;

    reverse = require("kopi/app/router").reverse;
    View = require("kopi/views").View;
    navigation = require("kopi/ui/navigation");
    viewswitchers = require("kopi/ui/viewswitchers");
    NavList = require("kopi/ui/lists").NavList;
    NavListItem = require("kopi/ui/lists/items").NavListItem;
    UIView = (function(_super) {
      __extends(UIView, _super);

      function UIView() {
        var backButton;

        UIView.__super__.constructor.apply(this, arguments);
        backButton = new navigation.NavButton({
          url: reverse("index"),
          titleText: "Back"
        });
        this.nav = new navigation.Nav({
          title: "UI",
          leftButton: backButton
        });
        this.view = new viewswitchers.View();
        this.list = new NavList();
      }

      UIView.prototype.oncreate = function() {
        var widget, widgets, _i, _len;

        this.app.navbar.add(this.nav);
        this.nav.skeleton();
        this.app.viewSwitcher.add(this.view);
        this.view.skeleton();
        widgets = [["Buttons", "/ui/buttons/"], ["Controls", "/ui/controls/"], ["Lists", "/ui/lists/"], ["Notification", "/ui/notification/"], ["Tabs", "/ui/tabs/"], ["Carousels", "/ui/carousels/"]];
        for (_i = 0, _len = widgets.length; _i < _len; _i++) {
          widget = widgets[_i];
          this.list.add(new NavListItem(this.list, widget));
        }
        this.list.skeletonTo(this.view.element);
        return UIView.__super__.oncreate.apply(this, arguments);
      };

      UIView.prototype.onstart = function() {
        this.app.navbar.show(this.nav);
        this.app.viewSwitcher.show(this.view);
        this.nav.render();
        this.view.render();
        this.list.render();
        return UIView.__super__.onstart.apply(this, arguments);
      };

      UIView.prototype.ondestroy = function() {
        this.list.destroy();
        this.nav.destroy();
        this.view.destroy();
        return UIView.__super__.ondestroy.apply(this, arguments);
      };

      return UIView;

    })(View);
    return {
      UIView: UIView
    };
  });

}).call(this);
