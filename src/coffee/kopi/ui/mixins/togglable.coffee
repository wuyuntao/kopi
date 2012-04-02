define "kopi/ui/mixins/togglable", (require, exports, module) ->

  ###
  Add show/hide method to class
  ###
  class Togglable

    show: ->
      return this if not this.hidden
      this.hidden = false
      this.element.addClass(this.constructor.cssClass("show"))
      this

    hide: ->
      return this if this.hidden
      this.hidden = true
      this.element.removeClass(this.constructor.cssClass("show"))
      this

  Togglable: Togglable
