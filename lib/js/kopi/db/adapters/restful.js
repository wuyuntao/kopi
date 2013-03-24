(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/db/adapters/restful", function(require, exports, module) {
    var RESTfulAdapter, server;
    server = require("kopi/db/adapters/server");
    /*
      Kopi provides a query API similar to CouchDB.
    
      Retrieve comments match conditions
      GET     /comments
      params  ?where={"body":{"contains":"lose"}}&sort={"id":true}&skip=2&limit=5
      success {"ok": true, "entries": [{"id": 1, "body": "Nothing left to lose}, ...]}
      error   {"error": true, "message": "500 server error"}
    
      Count comments match conditions
      GET     /comments
      params  ?where={"body":{"contains":"lose"}}&count=true
      success {"ok": true, "count": 5}
      error   {"error": true, "message": "500 server error"}
    
      Retrieve single comment
      GET     /comments/1
      success {"ok": true, "entry": {"id": 1, "body": "Nothing left to lose"}}
      error   {"error": true, "message": "comment not found"}
    
      Create single comment
      POST    /comments
      params  ?attrs={body:"Nothing left to lose"}
      success {"ok": true, "id": 1}
      error   {"error": true, "message": "body too short"}
    
      Update single comment
      PUT     /comments/1
      params  ?attrs={body:"Nothing left to lose"}
      success {"ok": true, "id": 1}
      error   {"error": true, "message": "body too short"}
    
      Destroy single comment
      DELETE  /comments/1
      success {"ok": true, "id": 1}
      error   {"error": true, "message": "db error"}
    
      Usage
    
      class CommentAdapter extends RESTfulAdapter
        this.configure
          collectionURL: "/comments"
          memberURL: "/users/:sid"
    
      # Search all comments created by some user and contains "kopi"
      adapter = new CommentAdapter()
      query = new RetrieveQuery
        only: ["sid"]
        where:
          userId: 1
          body:
            icontains: "kopi"
        sort:
          createdAt: true
        skip: 10
        limit: 10
      adapter.retrieve query, (error, message) ->
        if not error and not message.error
          comments = message.entries
    */

    RESTfulAdapter = (function(_super) {

      __extends(RESTfulAdapter, _super);

      function RESTfulAdapter() {
        return RESTfulAdapter.__super__.constructor.apply(this, arguments);
      }

      RESTfulAdapter.configure;

      /*
          Build URL from given query object
      */


      RESTfulAdapter.prototype._url = function(query, url) {
        var options, pk;
        pk = query.pk();
        options = this._options;
        url || (url = pk ? options.memberURL.replace(":pk", pk) : options.collectionURL);
        return RESTfulAdapter.__super__._url.call(this, query, url);
      };

      return RESTfulAdapter;

    })(server.ServerAdapter);
    return {
      RESTfulAdapter: RESTfulAdapter
    };
  });

}).call(this);
