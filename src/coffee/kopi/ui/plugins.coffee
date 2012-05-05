define "kopi/ui/plugins", (require, exports, module) ->

  # This module provide some simple jQuery plugin
  $ = require "jquery"
  app = require "kopi/app"

  $.fn.navlink = ->
    return this unless this.length

    this.each ->
      link = $(this)
      url = link.attr('href') or link.data('url')
      if url
        link.click (e) ->
          e.preventDefault()
          e.stopPropagation()
          app.instance().load(url)

  return
