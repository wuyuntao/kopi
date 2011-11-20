kopi.module("kopi.db.adapters.restful")
  .require("kopi.db.adapters.server")
  .define (exports, server) ->

    ###
    Kopi provides a query API similar to CouchDB.

    Retrieve comments match conditions
    GET /comments
    params {"where": {"body": {"contains": "lose"}}, "sort": {"id": true}, "skip": 2, "limit": 5}
    reply message
      success {"ok": true, "entries": [{"id": 1, "body": "Nothing left to lose}, ...]}
      error {"error": true, "message": "500 server error"}

    Count comments match conditions
    GET /comments
    params {"where": {"body": {"contains": "lose"}}, "count": true}
    reply message
      success {"ok": true, "count": 5}
      error {"error": true, "message": "500 server error"}

    Retrieve single comment
    GET /comments/1
    reply message
      success {"ok": true, "entry": {"id": 1, "body": "Nothing left to lose"}}
      error {"error": true, "message": "comment not found"}

    Create single comment
    POST /comments
    params {"body": "Nothing left to lose"}
    reply message
      success {"ok": true, "id": 1}
      error   {"error": true, "message": "body too short"}

    Update single comment
    PUT /comments/1
    params {"body": "Nothing left to lose"}
    reply message
      success {"ok": true, "id": 1}
      error   {"error": true, "message": "body too short"}

    Destroy single comment
    DELETE /comments/1
    reply message
      success {"ok": true, "id": 1}

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

      cls = this
      cls.configure
        createMethod: "POST"
        retrieveMethod: "GET"
        updateMethod: "PUT"
        destroyMethod: "DELETE"
        format: "JSON"
        # collectionURL: "/users/"
        # memberURL: "/user/:sid/"

      constructor: (options={}) ->
        super

      ###
      Build URL from given query object
      ###
      url: (query) ->

      ###
      Build request from given query object
      ###
      request: (query) ->

      ###
      Send request to server
      ###
      _send: (request) ->

    exports.RESTfulAdapter = RESTfulAdapter
