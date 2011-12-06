kopi.module("kopi.ui.images")
  .require("kopi.ui.widgets")
  .define (exports, widgets) ->

    IMG_TAG = "<img></img>"
    SRC = "src"

    ###
    A optimized image widget has following features.
    ###
    class Image extends widgets.Widget

      this.configure
        tagName: "figure"
        height: ""
        width: ""
        src: ""
        loaderSrc: ""
        fallbackSrc: ""

      constructor: ->
        super
        this._src = this._options.src

      image: (src) ->
        self = this
        self._src = src
        self.update() if self.rendered
        self

      onskeleton: ->
        self = this
        options = self._options
        self._image = $ IMG_TAG,
          src: options.loaderSrc,
          height: options.height
          width: options.width
        self.element.html(self._image)
        super

      onrender: ->
        this._draw()
        super

      onupdate: ->
        this._draw()
        super

      # TODO Show loader or default image when resource is not ready
      # TODO Allow to retry if download fails
      # TODO Image resources can be cached in db or localstorage as base64 string
      # TODO Simple process image with canvas?
      # TODO Do not subtitute image when page is scrolling
      _draw: ->
        self = this
        self._image.attr SRC, self._options.src

    exports.Image = Image
