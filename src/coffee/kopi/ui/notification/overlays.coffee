define "kopi/ui/notification/overlays", (require, exports, module) ->

  settings = require "kopi/settings"
  i18n = require "kopi/utils/i18n"
  widgets = require "kopi/ui/notification/widgets"

  class Overlay extends widgets.Widget

    this.widgetName "Overlay"

    onskeleton: ->
      # TODO Ignore touch events too
      this.element.bind "click", (e) -> return false
      super

    show: (transparent=false) ->
      cls = this.constructor
      self = this
      return self if not self.hidden
      self.hidden = false
      self.element
        .removeClass(cls.hideClass())
        .addClass(cls.showClass())
      self.element.addClass(cls.transparentClass()) if transparent
      self

    hide: ->
      cls = this.constructor
      self = this
      return self if self.hidden
      self.hidden = true
      self.element
        .addClass(cls.hideClass())
        .removeClass("#{cls.showClass()} #{cls.transparentClass()}")
      self

  # Singleton
  overlayInstance = null

  instance: ->
    overlayInstance or= new Overlay().skeleton().render()
  Overlay: Overlay
