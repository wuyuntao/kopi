kopi.module("kopi.app.router")
  .require("kopi.utils.url")
  .define (exports, url) ->

    ###
    URL 路由管理
    ###
    class Router
      constructor: ->
        this.routes = []
        this.statics = {}
        this.dynamics = []
        this.names = {}
        this.compiled = false
        # JavaScript does not support negative lookbehind assertion
        # this.syntax = /(?<!\\):([a-zA-Z_]+)?(?:#(.*?)#)?/i
        this.syntax = /:([a-zA-Z_]+)?(?:#(.*?)#)?/i
        this.base = '[^/]+'

      # Add a route.
      # The route string may contain `:key`, `:key#regexp#` or `:#regexp#` tokens
      # for each dynamic part of the route. These can be escaped with a backslash
      # in front of the `:` and are completely ignored if static is true.
      add: (route, view, context={}) ->
        route =
          route: route.replace('\\:', ':')
          realroute: route
          view: view
          tokens: route.split(this.syntax)
          context: context

        if not this.exists(route)
          this.routes.push(route)
          compiled = false

        this

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
            out += (part || this.base) + ')'
        out

      # Check if route is static
      isStatic: (route) ->
        route.tokens.length == 1

      # Match a path and return a route object
      match: (path, scope=null) ->
        request = url.parse(path)
        if request.path of this.statics
          route = this.statics[request.path]
          unless scope and route.context.scoped and not (scope instanceof route.view)
            return route: route, args: [request]

        for dynamic in this.dynamics
          matches = request.path.match(dynamics[i].regexp)
          if matches
            route = dynamic.route
            continue if scope and route.context.scoped and not scope instanceof route.view
            matches[0] = request
            return route: route, args: matches

        if scope
          return this.match(path, null)

        # Late check to reduce overhead on hits
        if not this.compiled
          this.compile()
          return this.match(path)

      # Build the search structures. call this before actually using the router.
      compile: ->
        this.reset()
        for route in this.routes
          if this.isStatic(route)
            this.statics[route.route] = route
            continue
          regexp = new RegExp('^' + this.group(route) + '$', 'i')
          this.dynamics.push regexp: regexp, route: route
        this.dynamics.reverse()
        this.compiled = true

      # Clean route caches and set compiled flag to false
      reset: ->
        this.compiled = false
        this.statics = {}
        this.dynamics = []
        this.names = {}

    router = new Router()

    add = -> router.add(arguments...)

    match = -> router.match(arguments...)

    exports.add = add
    exports.match = match
