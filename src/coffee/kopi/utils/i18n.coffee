kopi.module("kopi.utils.i18n")
  .require("kopi.utils")
  .define (exports, utils) ->

    # @type {LocaleString}      如果找不到翻译是的默认语言
    exports.fallback = "en"
    # @type {LocaleString}      当前应用使用的语言
    exports.locale = "en"
    # @type {Array}             所有的语言列表
    locales = ["en", "zh-CN"]
    # @type {Hash}              所有的翻译表
    messages = {}

    ###
    翻译

    @param  {String}  name      需要翻译的字符串键值
    @param  {Hash}    params    翻译所需的参数
    ###
    translate = (name, params) ->
      try
        utils.format(utils.search(name, messages[exports.locale]), params)
      catch e
        try
          utils.format(utils.search(name, messages[exports.fallback]), params)
        catch e
          throw new Error("Missing translation: '#{name}' [#{exports.locale}, #{exports.fallback}]")

    ###
    添加翻译文件

    @param  {String}  locale        翻译所属语言
    @param  {Hash}    translation   翻译内容
    ###
    define = (locale, translation) ->
      target = messages[locale] or= {}
      $.extend target, translation
      return

    exports.translate = exports.t = translate
    exports.define = define
