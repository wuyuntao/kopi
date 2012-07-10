(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/ui/notification", function(require, exports, module) {
    var DuplicateNotificationError, bubbles, dialogs, exceptions, i18n, indicators, overlays;
    i18n = require("kopi/utils/i18n");
    exceptions = require("kopi/exceptions");
    bubbles = require("kopi/ui/notification/bubbles");
    dialogs = require("kopi/ui/notification/dialogs");
    indicators = require("kopi/ui/notification/indicators");
    overlays = require("kopi/ui/notification/overlays");
    /*
      Error raised when dialog or other components are double activated
    */

    DuplicateNotificationError = (function(_super) {

      __extends(DuplicateNotificationError, _super);

      function DuplicateNotificationError() {
        return DuplicateNotificationError.__super__.constructor.apply(this, arguments);
      }

      return DuplicateNotificationError;

    })(exceptions.Exception);
    return {
      overlay: function() {
        return overlays.instance();
      },
      dialog: function() {
        return dialogs.instance();
      },
      indicator: function() {
        return indicators.instance();
      },
      bubble: function() {
        return bubbles.instance();
      },
      lock: function(transparent) {
        if (transparent == null) {
          transparent = false;
        }
        return overlays.instance().show({
          transparent: transparent
        });
      },
      unlock: function() {
        return overlays.instance().hide();
      },
      loading: function(transparent) {
        if (transparent == null) {
          transparent = false;
        }
        return indicators.instance().show({
          lock: true,
          transparent: transparent
        });
      },
      loaded: function() {
        return indicators.instance().hide();
      },
      message: function(text) {
        return bubbles.instance().content(text).show();
      }
    };
  });

}).call(this);
