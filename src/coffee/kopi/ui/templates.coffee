kopi.module("kopi.ui.templates")
  .require("kopi.exceptions")
  .define (exports) ->
    ###
    模板基类

    定义新的模板

    class HelloTemplate extends Template
      render: (data) ->
        "Hello, #{data.username}"

    # TODO 增加工厂方法来方便模板的定义？
    # TODO 支持其它 Template engine，如 ejs, jQuery or Mustache？
    ###
    class Template

      render: (data={}) ->
        ""

    exports.Template = Template
