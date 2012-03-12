define "kopi/ui/notification/indicators", (require, exports, module) ->

  settings = require "kopi/settings"
  i18n = require "kopi/utils/i18n"
  widgets = require "kopi/ui/notification/widgets"
  overlays = require "kopi/ui/notification/overlays"

  class Indicator extends widgets.Widget

    this.widgetName "Indicator"

    constructor: ->
      super()
      this._overlay = overlays.instance()

    onskeleton: ->
      super

    show: (options={}) ->
      cls = this.constructor
      self = this
      return self if not self.hidden
      options.lock = true if typeof options.lock is 'undefined'
      self.hidden = false
      self._overlay.show(options.transparent) if options.lock
      self.element.addClass(cls.showClass())
      self

    hide: ->
      cls = this.constructor
      self = this
      return self if self.hidden
      self.hidden = true
      self._overlay.hide()
      self.element.removeClass(cls.showClass())
      self

  # Singleton instance of indicator
  indicatorInstance = null

  # Factory method for singleton instance of indicator
  instance = ->
    indicatorInstance or= new Indicator().skeletonTo(document.body).render()

  # Shortcut methods to toggle indicator
  show = -> instance().show()
  hide = -> instance().hide()

  instance: instance
  show: show
  hide: hide
  Indicator: Indicator
