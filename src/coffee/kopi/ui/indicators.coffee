define "kopi/ui/indicators", (require, exports, module) ->

  klass = require "kopi/utils/klass"
  Togglable = require("kopi/ui/mixins/togglable").Togglable
  Widget = require("kopi/ui/widgets").Widget

  class Indicator extends Widget

    @widgetName "Indicator"

    klass.include this, Togglable

    @configure
      # @type  {Boolean} Center aligning
      center: false

    constructor: ->
      super
      if @_options.center
        cls = this.constructor
        @_options.extraClass += " #{cls.cssClass("center")}"
      @hidden = true

    ondestroy: ->
      # Reset hidden to true when destroying the widget
      @hidden = true

  Indicator: Indicator
