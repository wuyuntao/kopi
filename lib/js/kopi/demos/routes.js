(function() {
  define("kopi/demos/routes", function(require, exports, module) {
    var router, ui, uibuttons, uilists, uinotification, views;

    router = require("kopi/app/router");
    views = require("kopi/demos/views");
    ui = require("kopi/demos/views/ui");
    uibuttons = require("kopi/demos/views/uibuttons");
    uilists = require("kopi/demos/views/uilists");
    uinotification = require("kopi/demos/views/uinotification");
    router.view(views.IndexView).route("/", {
      name: "index"
    }).end().view(ui.UIView).route("/ui/", {
      name: "ui"
    }).end().view(uibuttons.UIButtonView).route("/ui/buttons/", {
      name: "ui-buttons"
    }).end().view(uilists.UIListView).route("/ui/lists/", {
      name: "ui-lists"
    }).end().view(uinotification.UINotificationView).route("/ui/notification/", {
      name: "ui-notification"
    }).end();
  });

}).call(this);
