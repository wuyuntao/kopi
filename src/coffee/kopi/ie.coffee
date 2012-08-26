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

  return
