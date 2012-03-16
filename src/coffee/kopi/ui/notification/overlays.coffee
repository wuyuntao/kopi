define "kopi/ui/notification/overlays", (require, exports, module) ->

  settings = require "kopi/settings"
  i18n = require "kopi/utils/i18n"
  widgets = require "kopi/ui/notification/widgets"

  class Overlay extends widgets.Widget

    this.widgetName("Overlay")

    onskeleton: ->
      # TODO Ignore touch events too
      this.element.bind "click", (e) ->
        e.preventDefault()
        e.stopPropagation()
      super

    show: (options={}) ->
      cls = this.constructor
      self = this
      if not self.hidden
        self.element.toggleClass(cls.transparentClass(), options.transparent)
        return self
      self.hidden = false
      self.element.addClass(cls.showClass())
      self.element.addClass(cls.transparentClass()) if options.transparent
      self

    hide: ->
      cls = this.constructor
      self = this
      return self if self.hidden
      self.hidden = true
      self.element.removeClass("#{cls.showClass()} #{cls.transparentClass()}")
      self

  # Singleton
  overlayInstance = null

  # Factory method to get singleton instance of overlay
  instance = ->
    overlayInstance or= new Overlay().skeletonTo(document.body).render()

  # A shortcut method to show or hide overlay
  show = ->
    instance().show(arguments...)

  hide = ->
    instance().hide()

  instance: instance
  show: show
  hide: hide
  Overlay: Overlay
