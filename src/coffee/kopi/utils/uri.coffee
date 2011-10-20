kopi.module("kopi.utils.uri")
  .require("kopi.exceptions")
  .require("kopi.utils.text")
  .define (exports, exceptions, text) ->

    doc = document
    loc = location

    ###
    Convert a relative URL into an absolute URI
    ###
    absolute = (url) -> join(base(), url)

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
      baseURI = document.href

    # TODO Cache decoded strings for performance
    decode = (value) -> if value then decodeURIComponent(value) else ''

    reHost = /^([^:\/#\?]+):\/\//
    ###
    生成类似 Rails Router 的路由

    TODO 更好的 path 格式
    ###
    build = (path, options={}) ->
      unless Array.isArray(path) and path.length >= 1
        throw new exceptions.ValueError("Path must be an non-empty array")

      path = path.concat ['.', options.format] if options.format?

      if options.params?
        if $.type(options.params) is 'object'
          options.params = "?#{$.param(options.params)}"
        path.push(options.params)

      if options.host?
        if options.host is true
          options.host = "#{loc.protocol}//#{loc.host}"
        else if not options.host.match(reHost)
          options.host = "#{loc.protocol}//#{options.host}"
        path.unshift(options.host)

      path.join ""

    ###
    Resolves a relative URL string to base URI
    ###
    join = (base, url) ->
      return url unless base
      return base unless url
      base = parse(base) if typeof base is 'string'
      url = parse(url) if typeof url is 'string'

      overridden = url.scheme
      if overridden
        base.scheme = url.scheme
      else
        overridden = url.authority

      if overridden
        base.authority = url.authority
      else
        overridden = url.path

      if overridden
        path = url.path
        # resolve path properly
        if path.charAt(0) != '/'
          # path is relative
          if base.authority and not base.path
            # console.log("case 1")
            # RFC 3986, section 5.2.3, case 1
            path = '/' + path
          else
            # RFC 3986, section 5.2.3, case 2
            lastSlashIndex = base.path.lastIndexOf('/')
            # console.log("case 2", lastSlashIndex)
            if lastSlashIndex != -1
              path = base.path.substr(0, lastSlashIndex + 1) + path
        # console.log removeDotSegments(path)
        base.path = removeDotSegments(path)
      else
        overridden = url.query

      if overridden
        base.query = url.query
      else
        overridden = url.fragment

      if overridden
        base.fragment = url.fragment

      unparse(base)

    ###
    Removes dot segments in given path component, as described in
    RFC 3986, section 5.2.4.
    ###
    removeDotSegments = (path) ->
      console.log(path)
      return '' if path == '..' or path == '.'
      # This optimization detects uris which do not contain dot-segments,
      # and as a consequence do not require any processing.
      return path unless './' in path or '/.' in path
      absolute = text.startsWith(path, '/')
      segments = path.split('/')
      length = segments.length
      results = []
      for segment, i in segments
        if segment == '.'
          results.push('') if absolute and i == length
        else if segment == '..'
          results.pop() if results.length > 1 or results.length == 1 && results[0] != ''
          results.push('') if absolute and i == length
        else
          results.push(segment)
          absolute = true
      results.join("/")

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
      matches = reURL.exec(url or "") or []
      # Create an object that allows the caller to access the sub-matches
      # by name. Note that IE returns an empty string instead of undefined,
      # like all other browsers do, so we normalize everything so its consistent
      # no matter what browser we're running on.
      results =
        url:          matches[0] || ""
        urlNoHash:    matches[1] || ""
        urlNoQuery:   matches[2] || ""
        domain:       matches[3] || ""
        scheme:       matches[4] || ""
        authority:    matches[5] || ""
        user:         matches[6] || ""
        username:     matches[7] || ""
        password:     matches[8] || ""
        host:         matches[9] || ""
        hostname:     matches[10] || ""
        port:         matches[11] || ""
        path:         matches[12] || ""
        directory:    matches[13] || ""
        filename:     matches[14] || ""
        query:        matches[15] || ""
        fragment:     matches[16] || ""
      results

    unparse = (obj) ->
      url = ""
      url += obj.scheme if obj.scheme
      url += "//" + obj.authority if obj.authority
      url += obj.path if obj.path
      url += obj.query if obj.query
      url += obj.fragment if obj.fragment
      url

    exports.absolute = absolute
    exports.base = base
    exports.build = build
    exports.join = join
    exports.parse = parse
    exports.unparse = unparse
