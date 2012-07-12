define "kopi/tests/ui/touchable", (require, exports, module) ->

  $ = require "jquery"
  Touchable = require("kopi/ui/touchable").Touchable
  Widget = require("kopi/ui/widgets").Widget
  g = require "kopi/ui/gestures"
  bubbles = require "kopi/ui/notification/bubbles"
  events = require "kopi/utils/events"
  css = require "kopi/utils/css"

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

    ontouchstart: (e) ->
      this._startEvent = e
      this._startPos = this._getPosition(e)
      this._startTouches = this._getTouches(e)
      this._startTime = e.timeStamp
      this._isTouched = true
      this._isSingleTouched = this._startTouches == 1

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

        this._isPinched = false
        this._isPinchEnd = false

      # 处理拖曳事件
      this._isFirstDrag = true

      this._isDragged = false
      this._isDragEnd = false

      if this._tapTimer
        clearTimeout this._tapTimer
        this._tapTimer = null

      # 扩展事件
      e.center = this._getCenter(this._startPos)

      this._widget.emit "touch", [e]

    ontouchmove: (e) ->
      return false unless this._isTouched

      this._moveEvent = e
      this._movePos = this._getPosition(e)
      this._moveCenter = this._getCenter(this._movePos)
      this._isSingleTouched = this._startTouches == 1

      # console.log this._movePos, this._startPos
      moveDistance = this._getDistance(this._startPos, this._movePos)
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
        e.center = this._moveCenter
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
        e.center or= this._moveCenter
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
      this._endCenter = this._getCenter(this._endPos)
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
        endDistance = this._getDistance(this._startPos, this._endPos)

      if this._isPinched and not this._isPinchEnd
        # TODO 考虑三个手指以上的缩放操作
        scale = this._getScale(this._startPos, this._endPos)
        # 缩放的中心点
        e.center = this._endCenter
        e.scale = scale

        this._isPinchEnd = true
        this._widget.emit "pinchend", [e]

      if this._isDragged and not this._isDragEnd
        angle = this._getAngleByDistance(endDistance)
        # Extend event
        e.angle = angle
        e.center or= this._endCenter
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

  class Photo extends Widget

    this.widgetName "Photo"

    constructor: (image, options) ->
      super(options)
      this.image = $(image)
      # 照片的初始位置 X
      this.startX = 0
      # 照片的初始位置 Y
      this.startY = 0

      # NOTE
      # 考虑到移动设备高分辨率，图片的显示大小应为
      # 原始大小的一半
      #
      # -- wuyuntao, 2012-07-12

      # 照片的原始宽度
      this.originalWidth = image.width / 2
      # 照片的原始高度
      this.originalHeight = image.height / 2
      # 照片的当前宽度
      this.width = image.width / 2
      # 照片的当前高度
      this.height = image.height / 2

    onskeleton: ->
      this.element.append(this.image)
      super

    ###
    检查如果照片移动到某个位置，照片是否应该被显示出来
    ###
    shouldBeActive: (pos) ->
      true

    moveToPos: (pos) ->
      console.log "Move photo to (#{pos.x}, #{pos.y})"

  class PhotoGallery extends Touchable

    this.widgetName "PhotoGallery"

    this.configure
      gestures: [CustomGesture]
      dragBounce: true
      dragMomentum: true
      dragDamping: 0.5
      dragDeceleration: 0.006
      startX: 0
      startY: 0
      originX: 0
      originY: 0

    constructor: ->
      super
      # 相册的初始位置 X
      this._x = this._options.startX
      # 相册的初始位置 Y
      this._y = this._options.startY
      # 相册的原始宽度
      this._originalWidth = 0
      # 相册的原始高度
      this._originalHeight = 0

      # 以最适合的比例为1
      this._scale = 1

      this._photos = []

    onskeleton: ->
      super

    onrender: ->
      this._originalWidth = this.element.width()
      this._originalHeight = this.element.height()

      console.log "original size: #{this._originalWidth}x#{this._originalHeight}"

      $("img", this.element).each (i, img) =>
        photo = new Photo(img)
          .skeletonTo(this.element)
          .render()
        this._photos.push(photo)
      super

    ontap: (e, event) ->
      console.log "Tap", event
      bubble = bubbles.instance()
      if bubble.hidden
        bubble.show("Tapped")
      else
        bubble.hide()

    ondoubletap: (e, event) ->
      console.log "DoubleTap", event

    ontouch: (e, event) ->
      this._pos = event.center
      console.log "Start position: ", event.center
      this._startTime = event.timeStamp

      if this._options.dragMomentum
        matrix = this.element.parseMatrix()
        if matrix and (matrix.x != this._x or matrix.y != this._y)
          this.element.unbind(events.WEBKIT_TRANSITION_END_EVENT)
          this._steps = []
          this._moveToPos(matrix)

    ondragstart: (e, event) ->
      console.log "DragStart", event
      pos = this._getDragPos(event)
      this._moveToPos(pos)

    ondragmove: (e, event) ->
      console.log "DragMove", event
      pos = this._getDragPos(event)
      this._moveToPos(pos)

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

    ###
    计算拖动的位置
    ###
    _getDragPos: (event) ->
      console.log "_getDragPos", event
      pos = event.center
      delta =
        x: pos.x - self._point.x
        y: pos.y - self._point.y

    ###
    移动容器
    ###
    _moveToPos: (pos) ->
      console.log "Move to #{pos.x}, #{pos.y}"
      this._x = pos.x
      this._y = pos.y
      # TODO
      # 具体实现：
      # 找到当前显示的图片，修改他们的样式以实现拖动
      # 对于不需要显示的图片仅更新他们的位置信息
      # for photo in this._photos
      #   photo.moveToPos(pos, photo.shouldBeActive(pos))

    ###
    计算拖动范围
    ###
    _getDragRange: ->
      res = {}
      res.minX = this._minDragX = 0
      res.minY = this._minDragY = 0
      res.maxX = this._maxDragX = this._originalWidth * this._photos.length
      res.maxY = this._maxDragY = this._originalHeight * this._photos.length
      res

    ###
    计算缩放范围
    ###
    _getScaleRange: ->
      res = {}
      # TODO
      # 具体实现：
      # 根据当前显示的图片大小
      # 以图片的最佳缩放比例为 1
      # 最小的缩放比例为 1/2
      # 最大的缩放比例为 2 倍

  $ ->
    new PhotoGallery()
      .skeleton("#container")
      .render()
