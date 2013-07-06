define "kopi/ie", ->

  # TODO
  # Shall we just use html5shiv instead?
  #
  # -- wuyuntao, 2012-08-18
  createElement = ->
    doc = document
    doc.createElement(tag) for tag in arguments
    return
  # Enable to use new elements in HTML5 for legacy IE.
  createElement 'header', 'hgroup', 'nav', 'menu', 'section',
    'article', 'aside', 'footer', 'figure', 'figurecaption'

  # Provide Function.name() method for IE
  RE_FUNCTION_NAME = /^\s*function\s*(\w*)\s*\(/
  if not createElement.name? and Object.defineProperty?
    Object.defineProperty Function.prototype, "name",
      get: ->
        name = this.toString().match(RE_FUNCTION_NAME)[1]
        # For better performance only parse once, and then cache the
        # result through a new accessor for repeated access.
        Object.defineProperty this, "name",
          value: name
        name

  return
