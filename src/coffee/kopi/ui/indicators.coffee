define "kopi/ui/indicators", (require, exports, module) ->

  klass = require "kopi/utils/klass"
  Togglable = require("kopi/ui/mixins/togglable").Togglable
  Widget = require("kopi/ui/widgets").Widget

  class Indicator extends Widget

    this.widgetName "Indicator"

    klass.include this, Togglable

    this.configure
      center: false

    constructor: ->
      super
      if this._options.center
        cls = this.constructor
        this._options.extraClass += " #{cls.cssClass("center")}"
      this.hidden = true

  Indicator: Indicator
