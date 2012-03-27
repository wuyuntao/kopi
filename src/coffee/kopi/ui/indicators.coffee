define "kopi/ui/indicators", (require, exports, module) ->

  Widget = require("kopi/ui/widgets").Widget

  class Indicator extends Widget

    this.widgetName "Indicator"

    constructor: ->
      super
      this.hidden = true

    show: ->
      cls = this.constructor
      self = this
      return self if not self.hidden
      self.hidden = false
      self.element.addClass(cls.cssClass("show"))
      self

    hide: ->
      cls = this.constructor
      self = this
      return self if self.hidden
      self.hidden = true
      self.element.removeClass(cls.cssClass("show"))
      self

  Indicator: Indicator
