(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/demos/views/uicarousels", function(require, exports, module) {
    var UICarouselView, View, array, carousels, navigation, reverse, viewswitchers;
    array = require("kopi/utils/array");
    reverse = require("kopi/app/router").reverse;
    View = require("kopi/views").View;
    navigation = require("kopi/ui/navigation");
    viewswitchers = require("kopi/ui/viewswitchers");
    carousels = require("kopi/ui/carousels");
    UICarouselView = (function(_super) {

      __extends(UICarouselView, _super);

      function UICarouselView() {
        var backButton;
        UICarouselView.__super__.constructor.apply(this, arguments);
        backButton = new navigation.NavButton({
          url: reverse("ui"),
          titleText: "Back"
        });
        this.nav = new navigation.Nav({
          title: "Carousel",
          leftButton: backButton
        });
        this.view = new viewswitchers.View();
        this.carousel = new carousels.Carousel();
      }

      UICarouselView.prototype.oncreate = function() {
        var i, page, _i;
        this.app.navbar.add(this.nav);
        this.nav.skeleton();
        this.app.viewSwitcher.add(this.view);
        this.view.skeleton();
        for (i = _i = 1; _i <= 10; i = ++_i) {
          page = new carousels.CarouselPage({
            imageSrc: "/images/pics/" + i + ".jpg"
          });
          this.carousel.add(page);
        }
        this.carousel.skeletonTo(this.view.element);
        return UICarouselView.__super__.oncreate.apply(this, arguments);
      };

      UICarouselView.prototype.onstart = function() {
        this.app.navbar.show(this.nav);
        this.app.viewSwitcher.show(this.view);
        this.nav.render();
        this.view.render();
        this.carousel.render();
        return UICarouselView.__super__.onstart.apply(this, arguments);
      };

      UICarouselView.prototype.ondestroy = function() {
        this.carousel.destroy();
        this.nav.destroy();
        this.view.destroy();
        return UICarouselView.__super__.ondestroy.apply(this, arguments);
      };

      return UICarouselView;

    })(View);
    return {
      UICarouselView: UICarouselView
    };
  });

}).call(this);
