kopi.module("kopi.utils.url")
  .define (exports) ->

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

    ###
    Parse a URL into a structure that allows easy access to
    all of the URL components by name.
    ###
    parse = (url) ->
      # If we're passed an object, we'll assume that it is
      # a parsed url object and just return it back to the caller.
      return url if typeof url is "object"

      results = {}
      matches = reURL.exec(url)
      if matches
        # Create an object that allows the caller to access the sub-matches
        # by name. Note that IE returns an empty string instead of undefined,
        # like all other browsers do, so we normalize everything so its consistent
        # no matter what browser we're running on.
        results =
          url:        matches[0] || ""
          urlNoHash:  matches[1] || ""
          urlNoQuery: matches[2] || ""
          domain:     matches[3] || ""
          protocol:   matches[4] || ""
          authority:  matches[5] || ""
          username:   matches[7] || ""
          password:   matches[8] || ""
          host:       matches[9] || ""
          hostname:   matches[10] || ""
          port:       matches[11] || ""
          path:       matches[12] || ""
          directory:  matches[13] || ""
          filename:   matches[14] || ""
          query:      matches[15] || ""
          hash:       matches[16] || ""
      results

    exports.parse = parse
