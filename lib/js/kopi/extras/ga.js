(function() {

  define("kopi/extras/ga", function(require, exports, module) {
    var $, Tracker, logger, logging, settings, win;
    $ = require("jquery");
    logging = require("kopi/logging");
    settings = require("kopi/settings");
    logger = logging.logger(module.id);
    win = window;
    /*
    An Adapter for Google Analytics SDK
    
    Usage:
      tracker.setup
        account:  "UA-xxxxx-x"
        domain: "kopi.com"
      tracker.load()
      tracker.pageview("/xs/46/")
      tracker.event("book", "download", "1")
    */

    Tracker = (function() {
      var kls;

      kls = Tracker;

      kls.VISITOR_LEVEL = 1;

      kls.SESSION_LEVEL = 2;

      kls.PAGE_LEVEL = 3;

      /*
      @constructor
      */


      function Tracker() {
        win._gaq || (win._gaq = []);
        this.account = null;
        this.domain = null;
      }

      /*
      Is GA script loaded successfully?
      */


      Tracker.prototype.isReady = function() {
        return typeof win._gat !== "undefined";
      };

      /*
      Add Google Analytics tracking script to page
      */


      Tracker.prototype.setup = function() {
        var ga, s, trackingSettings;
        if (this.isReady()) {
          return;
        }
        trackingSettings = settings.kopi.tracking;
        if (!trackingSettings.account) {
          logger.error("Account ID for Google Analytics must be specified.");
          return;
        }
        win._gaq.push(["_setAccount", trackingSettings.account]);
        win._gaq.push(["_setDomainName", trackingSettings.domain]);
        win._gaq.push(["_trackPageview"]);
        ga = document.createElement("script");
        ga.type = "text/javascript";
        ga.async = true;
        ga.src = (location.protocol === "https:" ? "https://ssl." : "http://www.") + "google-analytics.com/" + (settings.kopi.debug ? "u/ga_debug.js" : "ga.js");
        s = document.getElementsByTagName('script')[0];
        s.parentNode.insertBefore(ga, s);
      };

      /*
      Update a custom vars
      */


      Tracker.prototype.setVar = function(slot, key, value, level) {
        if (level == null) {
          level = kls.PAGE_LEVEL;
        }
        win._gaq.push(['_setCustomVar', slot, key, value, level]);
        return this;
      };

      /*
      Update custom vars
      */


      Tracker.prototype.setVars = function(vars, level) {
        var key, slot, value;
        if (vars == null) {
          vars = {};
        }
        if (level == null) {
          level = kls.PAGE_LEVEL;
        }
        slot = 1;
        for (key in vars) {
          value = vars[key];
          this.attrs(slot, key, value, level);
          slot++;
        }
        return this;
      };

      /*
      Track page view
      */


      Tracker.prototype.pageview = function(url) {
        win._gaq.push(["_trackPageview", url]);
      };

      /*
      Track event
      */


      Tracker.prototype.event = function(category, action, label, value) {
        if (label == null) {
          label = "";
        }
        if (value == null) {
          value = 0;
        }
        win._gaq.push(["_trackEvent", category, action, label, value]);
      };

      return Tracker;

    })();
    return {
      tracker: new Tracker()
    };
  });

}).call(this);
