kopi.module("kopi.templates")
  .require("kopi.utils.text")
  .define (exports, text) ->

    ###
    Interface for all template engines
    ###
    class Template

      constructor: ->

      render: (data) ->

    ###
    Simple template engine
    ###
    class SimpleTemplate

      constructor: (template="") ->
        this._template = template

      render: (data={}) ->
        text.render(this._template, data)

    exports.Template = Template
    exports.SimpleTemplate = SimpleTemplate

    # Render function
    simple = (template, data) -> new SimpleTemplate(template).render(data)
    exports.simple = simple

    if $.fn.tmpl
      ###
      Template engine for jQuery Templates Plugin
      ###
      class JQueryTemplate
        constructor: (template) ->
          this._template = $(template)

        render: (data={}) ->
          this._template.tmpl(data)

      jquery = (template, data) -> new jQuery(template).render(data)

      exports.JQueryTemplate = JQueryTemplate
      exports.jquery = jquery
