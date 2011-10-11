kopi.module("kopi.ui.viewport")
  .require("kopi.ui.widgets")
  .define (exports) ->

    ###
    视区

    主要用来响应窗口的大小变化

    所有需要根据窗口大小重新布局的 Widget 应该向 Viewport 注册
    当窗口大小发生变化视，视区锁屏，向所有已注册的 Widget 发送事件
    Widget 响应事件被在完成后向 Viewport 发送完成时间
    当所有 Widget 全部完成后，Viewport 将视区解锁

    TODO 是否只是向激活的 Widget 发送事件，那如果重新载入非激活的 Widget 的时候怎么办？

    ###
    class Viewport extends widgets.Widget

    exports.Viewport = Viewport
