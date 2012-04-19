define "kopi/ui/templates", (require, exports, module) ->

  $ = require "jquery"
  text = require "kopi/utils/text"

  ###
  Interface for all template engines

  class Template

    constructor: ->

    render: (data) ->
  ###

  ###
  Simple template engine
  ###
  class SimpleTemplate

    constructor: (template="") ->
      this._template = template

    render: (data={}) ->
      text.format(this._template, data)

  # Render function
  simple = (template, data) -> new SimpleTemplate(template).render(data)

  SimpleTemplate: SimpleTemplate
  simple: simple
