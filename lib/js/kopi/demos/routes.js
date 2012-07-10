(function() {

  define("kopi/demos/routes", function(require, exports, module) {
    var router, ui, uibuttons, uicarousels, uilists, uinotification, uitabs, views;
    router = require("kopi/app/router");
    views = require("kopi/demos/views");
    ui = require("kopi/demos/views/ui");
    uilists = require("kopi/demos/views/uilists");
    uibuttons = require("kopi/demos/views/uibuttons");
    uinotification = require("kopi/demos/views/uinotification");
    uitabs = require("kopi/demos/views/uitabs");
    uicarousels = require("kopi/demos/views/uicarousels");
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
    }).end().view(uitabs.UITabView).route("/ui/tabs/", {
      name: "ui-tabs"
    }).end().view(uicarousels.UICarouselView).route("/ui/carousels/", {
      name: "ui-carousels"
    }).end();
  });

}).call(this);
