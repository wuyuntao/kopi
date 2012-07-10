(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/demos/views/uinotification", function(require, exports, module) {
    var Button, UINotificationView, View, navigation, notification, reverse, templates, viewswitchers;
    View = require("kopi/views").View;
    navigation = require("kopi/ui/navigation");
    viewswitchers = require("kopi/ui/viewswitchers");
    reverse = require("kopi/app/router").reverse;
    templates = require("kopi/demos/templates/uinotification");
    Button = require("kopi/ui/buttons").Button;
    notification = require("kopi/ui/notification");
    UINotificationView = (function(_super) {

      __extends(UINotificationView, _super);

      function UINotificationView() {
        var backButton;
        UINotificationView.__super__.constructor.apply(this, arguments);
        backButton = new navigation.NavButton({
          url: reverse("ui"),
          titleText: "Back"
        });
        this.nav = new navigation.Nav({
          title: "Notification",
          leftButton: backButton
        });
        this.view = new viewswitchers.View({
          template: templates.notification
        });
        this.indicatorButton = new Button({
          titleText: "Show indicator"
        });
        this.indicatorButton.on(Button.CLICK_EVENT, function() {
          notification.indicator().show();
          return setTimeout((function() {
            return notification.indicator().hide();
          }), 3000);
        });
        this.bubbleButton = new Button({
          titleText: "Show bubble"
        });
        this.bubbleButton.on(Button.CLICK_EVENT, function() {
          return notification.bubble().show("This is a bubble", {
            lock: true,
            duration: 3000
          });
        });
        this.dialogButton = new Button({
          titleText: "Show dialog"
        });
        this.dialogButton.on(Button.CLICK_EVENT, function() {
          return notification.dialog().title("This is a dialog").content("Say something...").show({
            lock: true
          });
        });
      }

      UINotificationView.prototype.oncreate = function() {
        this.app.navBar.add(this.nav);
        this.nav.skeleton();
        this.app.viewSwitcher.add(this.view);
        this.view.skeleton();
        this.indicatorButton.skeletonTo($(".indicator-section", this.view.element));
        this.bubbleButton.skeletonTo($(".bubble-section", this.view.element));
        this.dialogButton.skeletonTo($(".dialog-section", this.view.element));
        return UINotificationView.__super__.oncreate.apply(this, arguments);
      };

      UINotificationView.prototype.onstart = function() {
        this.app.navBar.show(this.nav);
        this.app.viewSwitcher.show(this.view);
        this.nav.render();
        this.view.render();
        this.indicatorButton.render();
        this.bubbleButton.render();
        this.dialogButton.render();
        return UINotificationView.__super__.onstart.apply(this, arguments);
      };

      UINotificationView.prototype.ondestroy = function() {
        this.indicatorButton.destroy();
        this.bubbleButton.destroy();
        this.dialogButton.destroy();
        this.nav.destroy();
        this.view.destroy();
        return UINotificationView.__super__.ondestroy.apply(this, arguments);
      };

      return UINotificationView;

    })(View);
    return {
      UINotificationView: UINotificationView
    };
  });

}).call(this);
