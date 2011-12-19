kopi.module("kopi.app.router")
  .require("kopi.utils.uri")
  .define (exports, uri) ->

    ###
    URL 路由管理

    Usage

      router
        .view(BookListView)
          .route("/book", name: "book-list")
          .route("/book/search", name: "book-search")
          .route("/book/:category, name: "book-category", group: "category")
          .end()
        .view(BookDetailView)
          .route("/book/:id", name: "book-detail", group: "id")
          .route("/book/:id/chapter", name: "chapter-list", group: "id")
          .end()
        .view(ChapterDetailView)
          .route("/book/:bid/chapter/:chid", name: "chapter-detail", group: ["bid", "chid"])
          .end()
        ...

    ###
    class Router
      constructor: ->
        self = this
        self.routes = []
        self.statics = {}
        self.dynamics = []
        self.names = {}
        self.compiled = false
        # JavaScript does not support negative lookbehind assertion
        # self.syntax = /(?<!\\):([a-zA-Z_]+)?(?:#(.*?)#)?/i
        self.syntax = /:([a-zA-Z_]+)?(?:#(.*?)#)?/i
        self.base = '[^/]+'

      ###
      Add a route.
      The route string may contain `:key`, `:key#regexp#` or `:#regexp#` tokens
      for each dynamic part of the route. These can be escaped with a backslash
      in front of the `:` and are completely ignored if static is true.

      @param {Object} option
      @option {String} name
      @option {Boolean|String|Array} group
        If `group` is `true`, use same view for every URL matches route
        If `group` is `false`, use unique view for every different URL
        If `group` is String or Array, views are grouped by specific arguments

      ###
      add: (route, view, option={}) ->
        self = this
        route =
          route: route.replace('\\:', ':')
          realroute: route
          view: view
          tokens: route.split(this.syntax)
          name: option.name
          group: option.group
        if not self.exists(route)
          self.routes.push(route)
          self.compiled = false
        self

      # Check if a route is already defined
      exists: (route) ->
        for exist in this.routes
          return true if route.realroute is exist.realroute
        false

      # Return a regexp pattern with groups
      group: (route) ->
        out = ''
        for part, i in route.tokens
          if (i % 3 == 0)
            out += part.replace('\:', ':').replace('(', '\\(').replace(')', '\\)')
          else if (i % 3 == 1)
            out += '('   # Javascript does not support named groups
          else
            out += (part or this.base) + ')'
        out

      # Check if route is static
      isStatic: (route) ->
        route.tokens.length == 1

      # Match a path and return a route object
      match: (path, scope=null) ->
        self = this
        request = uri.parse(path)
        if request.path of self.statics
          route = self.statics[request.path]
          return route: route, args: [request]

        for dynamic in self.dynamics
          matches = request.path.match(dynamic.regexp)
          if matches
            route = dynamic.route
            matches[0] = request
            return route: route, args: matches

        # Late check to reduce overhead on hits
        if not self.compiled
          self.compile()
          return self.match(path)

      # Build the search structures. call this before actually using the router.
      compile: ->
        self = this
        self.reset()
        for route, i in self.routes
          console.log "router #{i}"
          console.log route
          console.log self.isStatic(route)
          if route.name
            self.names[route.name] = route
          if self.isStatic(route)
            self.statics[route.route] = route
            continue
          regexp = new RegExp('^' + self.group(route) + '$', 'i')
          self.dynamics.push regexp: regexp, route: route
        self.dynamics.reverse()
        self.compiled = true
        self

      # Clean route caches and set compiled flag to false
      reset: ->
        self = this
        self.compiled = false
        self.statics = {}
        self.dynamics = []
        self.names = {}
        self

    # Singleton instance of router
    router = new Router()

    instance = -> router

    match = -> router.match(arguments...)

    reverse = (name) ->
      router.names[name]

    ###
    Return a view object to add route
    ###
    view = (view) ->
      route: (route, option) -> router.add(route, view, option)
      end: -> router

    exports.instance = instance
    exports.match = match
    exports.reverse = reverse
    exports.view = view
