// Generated by CoffeeScript 1.3.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  define("kopi/clients/chromium", function(require, exports, module) {
    var ChromiumClient, base, clients;
    base = require("kopi/clients/base");
    clients = require("kopi/clients");
    ChromiumClient = (function(_super) {

      __extends(ChromiumClient, _super);

      ChromiumClient.name = 'ChromiumClient';

      function ChromiumClient() {
        return ChromiumClient.__super__.constructor.apply(this, arguments);
      }

      return ChromiumClient;

    })(base.BaseClient);
    clients.register("chromium", ChromiumClient);
    return {
      ChromiumClient: ChromiumClient
    };
  });

}).call(this);