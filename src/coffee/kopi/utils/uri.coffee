kopi.module("kopi.utils.uri")
  .require("kopi.exceptions")
  .require("kopi.utils.array")
  .require("kopi.utils.object")
  .require("kopi.utils.text")
  .define (exports, exceptions, array, object, text) ->

    doc = document
    loc = location
    sep = '/'
    cur = '.'
    par = '..'
    emp = ''

    ###
    Convert a relative URL into an absolute URI
    ###
    absolute = (url, baseURL) ->
      baseURL = base() if not baseURL
      join(baseURL, url)

    ###
    Convert an absolute URI into a relative URI
    ###
    relative = (url, baseURL) ->
      baseURL = current() if not baseURL
      unjoin(baseURL, url)

    ###
    获取当前页面 baseURI
    ###
    baseURI = null
    base = ->
      return baseURI if baseURI
      if doc.baseURI
        baseURI = parse(doc.baseURI)
        return baseURI
      tag = $('head > base')
      if tag.length
        baseURI = parse(join(loc.href, tag.attr("href")))
        return baseURI
      baseURI = parse loc.href

    ###
    Get current URL
    ###
    current = -> loc.href

    # TODO Cache decoded strings for performance
    decode = (value) -> if value then decodeURIComponent(value) else emp

    reHost = /^([^:\/#\?]+):\/\//
    ###
    生成类似 Rails Router 的路由

    TODO 更好的 path 格式
    ###
    build = (path, options={}) ->
      unless Array.isArray(path) and path.length >= 1
        throw new exceptions.ValueError("Path must be an non-empty array")

      path = path.concat [cur, options.format] if options.format?

      if options.params?
        if object.isObject(options.params)
          options.params = "?#{$.param(options.params)}"
        path.push(options.params)

      if options.host?
        if options.host is true
          options.host = "#{loc.protocol}//#{loc.host}"
        else if not options.host.match(reHost)
          options.host = "#{loc.protocol}//#{options.host}"
        path.unshift(options.host)

      path.join emp

    goto = (url) -> loc.href = url

    ###
    Resolves a relative URL string to base URI
    ###
    join = (base, url) ->
      return url unless base
      return base unless url
      base = parse(base) if text.isString(base)
      url = parse(url) if text.isString(url)

      overridden = url.scheme
      if overridden then base.scheme = url.scheme else overridden = url.authority
      if overridden then base.authority = url.authority else overridden = url.path

      if overridden
        path = url.path
        # resolve path properly
        if path.charAt(0) != sep
          # path is relative
          if base.authority and not base.path
            # RFC 3986, section 5.2.3, case 1
            path = sep + path
          else
            # RFC 3986, section 5.2.3, case 2
            lastSlashIndex = base.path.lastIndexOf(sep)
            if lastSlashIndex != -1
              path = base.path.substr(0, lastSlashIndex + 1) + path
        base.path = removeDotSegments(path)
      else
        overridden = url.query

      if overridden then base.query = url.query else overridden = url.fragment
      if overridden then base.fragment = url.fragment

      unparse(base)

    ###
    Removes dot segments in given path component, as described in
    RFC 3986, section 5.2.4.
    ###
    removeDotSegments = (path) ->
      return emp if path == par or path == cur
      # This optimization detects uris which do not contain dot-segments,
      # and as a consequence do not require any processing.
      return path unless text.contains(path, "./") or text.contains(path, "/.")
      absolute = text.startsWith(path, sep)
      segments = path.split(sep)
      length = segments.length
      results = []
      for segment, i in segments
        if segment == cur
          results.push(emp) if absolute and i == length
        else if segment == par
          results.pop() if results.length > 1 or results.length == 1 && results[0] != emp
          results.push(emp) if absolute and i == length
        else
          results.push(segment)
          absolute = true
      results.join(sep)

    ###
    Return a relative URL string from base URI

    TODO Move some common methods to path module
    ###
    unjoin = (base, url) ->
      return url unless base
      return base unless url
      base = parse(base) if text.isString(base)
      url = parse(url) if text.isString(url)

      # Return absolute url if scheme or authority are different
      if base.scheme != url.scheme or base.authority != url.authority
        return unparse(url)

      # Get dir name of path
      lastSlashIndex = base.path.lastIndexOf(sep)
      if lastSlashIndex != -1
        basePath = base.path.substr(0, lastSlashIndex + 1)
      lastSlashIndex = url.path.lastIndexOf(sep)
      if lastSlashIndex != -1
        path = url.path.substr(0, lastSlashIndex + 1)
        filename = url.path.substr(lastSlashIndex + 1, url.path.length)
      basePath = (x for x in basePath.split(sep) when x)
      path = (x for x in path.split(sep) when x)

      # Work out how much of the path is shared
      count = Math.min(basePath.length, path.length)
      for i in [0...count]
        if basePath[i] != path[i]
          count = i
          break

      relative = array.fill(par, basePath.length - count).concat(path[count...path.length])
      # Restore last slash if filename is empty
      relative.push(filename)

      url.scheme = ""
      url.authority = ""
      url.path = relative.join(sep)
      unparse(url)

    ###
    This scary looking regular expression parses an absolute URL or its relative
    variants (protocol, site, document, query, and hash), into the various
    components (protocol, host, path, query, fragment, etc that make up the
    URL as well as some other commonly used sub-parts. When used with RegExp.exec()
    or String.match, it parses the URL into a results array that looks like this:

        [0]: http://jblas:password@mycompany.com:8080/mail/inbox?msg=1234&type=unread#msg-content
        [1]: http://jblas:password@mycompany.com:8080/mail/inbox?msg=1234&type=unread
        [2]: http://jblas:password@mycompany.com:8080/mail/inbox
        [3]: http://jblas:password@mycompany.com:8080
        [4]: http:
        [5]: jblas:password@mycompany.com:8080
        [6]: jblas:password
        [7]: jblas
        [8]: password
        [9]: mycompany.com:8080
       [10]: mycompany.com
       [11]: 8080
       [12]: /mail/inbox
       [13]: /mail/
       [14]: inbox
       [15]: ?msg=1234&type=unread
       [16]: #msg-content
    ###
    reURL = /^(((([^:\/#\?]+:)?(?:\/\/((?:(([^:@\/#\?]+)(?:\:([^:@\/#\?]+))?)@)?(([^:\/#\?]+)(?:\:([0-9]+))?))?)?)?((\/?(?:[^\/\?#]+\/+)*)([^\?#]*)))?(\?[^#]+)?)(#.*)?/
    rePath = /^\//

    ###
    Parse a URL into a structure that allows easy access to
    all of the URL components by name.
    ###
    parse = (url) ->
      # If we're passed an object, we'll assume that it is
      # a parsed url object and just return it back to the caller.
      return url if typeof url is "object"

      results = {}
      matches = reURL.exec(url or emp) or []
      # Create an object that allows the caller to access the sub-matches
      # by name. Note that IE returns an empty string instead of undefined,
      # like all other browsers do, so we normalize everything so its consistent
      # no matter what browser we're running on.
      results =
        url:          matches[0] || emp
        urlNoHash:    matches[1] || emp
        urlNoQuery:   matches[2] || emp
        domain:       matches[3] || emp
        scheme:       matches[4] || emp
        authority:    matches[5] || emp
        user:         matches[6] || emp
        username:     matches[7] || emp
        password:     matches[8] || emp
        host:         matches[9] || emp
        hostname:     matches[10] || emp
        port:         matches[11] || emp
        path:         matches[12] || emp
        directory:    matches[13] || emp
        filename:     matches[14] || emp
        query:        matches[15] || emp
        fragment:     matches[16] || emp
      results

    unparse = (obj) ->
      url = emp
      url += obj.scheme if obj.scheme
      url += "//" + obj.authority if obj.authority
      url += obj.path if obj.path
      url += obj.query if obj.query
      url += obj.fragment if obj.fragment
      url

    exports.absolute = absolute
    exports.relative = relative
    exports.base = base
    exports.current = current
    exports.build = build
    exports.join = join
    exports.unjoin = unjoin
    exports.parse = parse
    exports.unparse = unparse
