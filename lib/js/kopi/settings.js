(function() {
  var __slice = [].slice;

  define("kopi/settings", function(require, exports, module) {
    var $, NotImplementedError, commit, kopi, load;
    $ = require("jquery");
    NotImplementedError = require("kopi/exceptions").NotImplementedError;
    kopi = {
      debug: true,
      app: {
        task: false,
        startURL: null,
        usePushState: true,
        useHashChange: true,
        useInterval: true,
        interval: 50,
        alwaysUseHash: true,
        redirectWhenNoRouteFound: false
      },
      i18n: {
        locale: "en",
        fallback: "en"
      },
      logging: {
        level: 0
      },
      ui: {
        prefix: "kopi",
        notification: {
          prefix: "kopi-notification"
        },
        imageDir: "/images"
      },
      db: {
        indexedDB: {
          name: "kopi_db"
        }
      },
      tracking: {
        account: null,
        domain: location.host
      }
    };
    load = function() {
      throw new NotImplementedError();
    };
    commit = function() {
      throw new NotImplementedError();
    };
    return {
      kopi: kopi,
      load: load,
      commit: commit,
      extend: function() {
        return $.extend.apply($, [true, exports].concat(__slice.call(arguments)));
      }
    };
  });

}).call(this);
