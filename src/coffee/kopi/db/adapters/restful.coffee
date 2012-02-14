kopi.module("kopi.db.adapters.restful")
  .require("kopi.db.adapters.server")
  .require("kopi.utils.uri")
  .define (exports, server, uri) ->

    ###
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

    ###
    class RESTfulAdapter extends server.ServerAdapter

      this.configure
        # collectionURL: "/api/users/"
        # memberURL: "/api/user/:pk/"

      ###
      Build URL from given query object
      ###
      _url: (query, url) ->
        pk = query.pk()
        options = this._options
        url or= if pk then options.memberURL.replace(":pk", pk) else options.collectionURL
        super(query, url)

    exports.RESTfulAdapter = RESTfulAdapter
