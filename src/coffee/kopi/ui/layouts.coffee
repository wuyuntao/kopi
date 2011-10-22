kopi.module("kopi.ui.layouts")
  .require("kopi.settings")
  .require("kopi.ui.navigation")
  .require("kopi.ui.views")
  .define (exports, settings, navigation, views) ->

    class Layout

      constructor: (components={}) ->
        this._components = components

      add: (component) ->
        this._components.push(component)
        this

      load: ->
        for name, component of components
          component.load(arguments...)

    # A factory method to create layout
    layout = (components=[]) -> new Layout(components)

    exports.Layout = Layout
    exports.layout = layout

    $ ->
      # Default layout
      exports.default = new Layout
        navbar: new navigation.Navbar(settings.kopi.ui.layout.navbar)
        container: new views.ViewContainer(settings.kopi.ui.layout.container)
