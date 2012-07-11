define "kopi/tests/ui/touchable", (require, exports, module) ->

  $ = require "jquery"
  Touchable = require("kopi/ui/touchable").Touchable
  g = require "kopi/ui/gestures"

  math = Math

  class CustomGesture extends g.Base

    this.configure
      preventDefault: true
      # @type  {Number} px
      tapDistance: 20
      # @type  {Number} ms
      tapInterval: 300
      # @type  {Number} px
      dragMinDistance: 20
      # @type  {Number} ms
      swipeTime: 200

    constructor: ->
      super

    ontouchstart: (e) ->
      this._startEvent = e
      this._startPos = this._getPosition(e)
      this._startTouches = this._getTouches(e)
      this._startTime = e.timeStamp
      this._isTouched = true
      this._isSingleTouched = this._startTouches == 1
      # console.log "ontouchstart", e
      # console.log this._startPos
      # console.log this._startTime
      # console.log this._startTouches

      # 只有在单指触摸的情况下，才考虑触发 tap 事件
      if this._isSingleTouched
        this._tapMoved = false
        # 如果前一次 tap 的时间戳和当前时间戳间隔小于阈值时
        # 且前一次 tap 的位置和当前位置间隔小于阈值时
        # 认为可能触发双击事件
        this._canBeDoubleTap = this._lastTapTime and
          (this._startTime - this._lastTapTime < this._options.tapInterval) and
          this._lastTapPos and
          (this._getDistance(this._lastTapPos, this._startPos).dist < this._options.tapDistance)

      # 只有在多指触摸时，才考虑触发 pinch 事件
      else
        this._isFirstPinch = true

      this._isFirstDrag = true

      this._isDragged = false
      this._isDragEnd = false

      this._isPinched = false
      this._isPinchEnd = false

      if this._tapTimer
        clearTimeout this._tapTimer
        this._tapTimer = null

    ontouchmove: (e) ->
      return false unless this._isTouched

      this._moveEvent = e
      this._movePos = this._getPosition(e)
      this._moveTime = e.timeStamp
      this._isSingleTouched = this._startTouches == 1

      moveDistance = this._getDistance(this._movePos, this._startPos)
      # 只有在单指触摸的情况下，才考虑触发 tap 事件
      if this._isSingleTouched
        if not this._tapMoved
          # console.log "move", moveDistance
          if moveDistance.dist > this._options.tapDistance
            this._tapMoved = true
            this._canBeDoubleTap = false
      else
        # 在多指触摸时，考虑缩放问题

        # TODO 考虑三个手指以上的缩放操作
        scale = this._getScale(this._startPos, this._movePos)
        # console.log "scale: " + scale

        # 缩放的中心点
        this._scalePos =
          x: (this._movePos[0].x + this._movePos[1].x) / 2
          y: (this._movePos[0].y + this._movePos[1].y) / 2

        e.position = this._scalePos
        e.scale = scale

        if this._isFirstPinch
          this._widget.emit "pinchstart", [e]
          this._isFirstPinch = false
        else
          this._widget.emit "pinchmove", [e]

        this._isPinched = true

        e.preventDefault()
        e.stopPropagation()


      # 只有当手指移动到最小阈值智商时，开始处理 drag 事件
      if moveDistance.dist > this._options.dragMinDistance

        # 才触发 Drag 事件
        angle = this._getAngleByDistance(moveDistance)
        # console.log "drag: #{moveDistance.dist}, #{angle}"

        # Extend event
        e.angle = angle
        e.direction = this._getDirection(angle)
        e.distance = moveDistance.dist
        e.distanceX = moveDistance.distX
        e.distanceY = moveDistance.distY

        if this._isFirstDrag
          this._widget.emit "dragstart", [e]
          this._isFirstDrag = false
        else
          this._widget.emit "dragmove", [e]

        this._isDragged = true

        e.preventDefault()
        e.stopPropagation()

    ontouchend: (e) ->
      return false unless this._isTouched

      this._endEvent = e
      this._endPos = this._movePos or this._startPos
      this._endTime = e.timeStamp

      if this._isSingleTouched and not this._tapMoved
        e.preventDefault()
        e.stopPropagation()
        # 等待一段时间，确定没有第二次点击时，再触发 tap 事件
        delayFn = =>
          this._widget.emit (if this._canBeDoubleTap then "doubletap" else "tap"), [e]
          this._tapTimer = null
          this._lastTapTime = null
          this._lastTapPos = null
        this._tapTimer = setTimeout(delayFn, this._options.tapInterval)
        this._lastTapTime = this._endTime
        this._lastTapPos = this._endPos
        # console.log this._lastTapTime, this._lastTapPos
        return

      if this._endPos
        endDistance = this._getDistance(this._endPos, this._startPos)

      if this._isPinched and not this._isPinchEnd
        # TODO 考虑三个手指以上的缩放操作
        scale = this._getScale(this._startPos, this._endPos)
        # 缩放的中心点
        this._scalePos =
          x: (this._endPos[0].x + this._endPos[1].x) / 2
          y: (this._endPos[0].y + this._endPos[1].y) / 2

        e.position = this._scalePos
        e.scale = scale

        this._isPinchEnd = true
        this._widget.emit "pinchend", [e]

      if this._isDragged and not this._isDragEnd
        angle = this._getAngleByDistance(endDistance)
        # Extend event
        e.angle = angle
        e.direction = this._getDirection(angle)
        e.distance = endDistance.dist
        e.distanceX = endDistance.distX
        e.distanceY = endDistance.distY

        # 如果手指触屏时间小于一定时间，触发 swipe 事件
        if this._endTime - this._startTime < this._options.swipeTime
          # console.log this._endTime, this._startTime, this._endTime - this._startTime
          this._widget.emit "swipe", [e]
          this._widget.emit "swipe" + e.direction, [e]

        this._isDragEnd = true
        this._widget.emit "dragend", [e]

    ontouchcancel: (e) -> this.ontouchend(e)


  class PhotoGallery extends Touchable

    this.widgetName "PhotoGallery"

    this.configure
      gestures: [CustomGesture]

    constructor: ->
      super
      this.images = []

    onskeleton: ->
      super

    onrender: ->
      $("img", this.element).each =>
        img = $(this)
        img
          .data("width", this.width)
          .data("height", this.height)
        this.images.push(img)
      super

    ontap: (e, event) ->
      console.log "Tap", event

    ondoubletap: (e, event) ->
      console.log "DoubleTap", event

    ondragstart: (e, event) ->
      console.log "DragStart", event

    ondragmove: (e, event) ->
      console.log "DragMove", event

    ondragend: (e, event) ->
      console.log "DragEnd", event

    onswipe: (e, event) ->
      console.log "Swipe", event

    onswipeleft: (e, event) ->
      console.log "SwipeLeft", event

    onswiperight: (e, event) ->
      console.log "SwipeRight", event

    onpinchstart: (e, event) ->
      console.log "PinchStart: " + event.scale

    onpinchmove: (e, event) ->
      console.log "PinchChange: " + event.scale

    onpinchend: (e, event) ->
      console.log "PinchEnd: " + event.scale

  $ ->
    new PhotoGallery()
      .skeleton("#container")
      .render()
