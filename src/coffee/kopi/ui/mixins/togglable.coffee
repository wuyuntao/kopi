define "kopi/ui/mixins/togglable", (require, exports, module) ->

  ###
  Add show/hide method to class
  ###
  class Togglable

    show: ->
      return this if not @hidden
      cls = this.constructor
      cls.SHOW_CLASS or= cls.cssClass("show")
      @element.addClass(cls.SHOW_CLASS)
      @hidden = false
      this

    hide: ->
      return this if @hidden
      cls = this.constructor
      cls.SHOW_CLASS or= cls.cssClass("show")
      @element.removeClass(cls.SHOW_CLASS)
      @hidden = true
      this

  Togglable: Togglable
