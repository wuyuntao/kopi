define "kopi/utils/i18n", (require, exports, module) ->

  $ = require "jquery"
  exceptions = require "kopi/exceptions"
  settings = require "kopi/settings"
  utils = require "kopi/utils"
  text = require "kopi/utils/text"

  # @type {Array}             所有的语言列表
  locales = ["en", "zh_CN"]
  # @type {Hash}              所有的翻译表
  messages = {}

  ###
  翻译缺失
  ###
  class TranslationError extends exceptions.Exception
    constructor: (name) ->
      super("Missing translation \"#{name}\", [#{settings.kopi.i18n.locale}, #{settings.kopi.i18n.fallback}]")

  ###
  翻译

  @param  {String}  name      需要翻译的字符串键值
  @param  {Hash}    params    翻译所需的参数
  ###
  translate = (name, params) ->
    try
      text.format(text.constantize(name, messages[settings.kopi.i18n.locale]), params)
    catch e
      try
        text.format(text.constantize(name, messages[settings.kopi.i18n.fallback]), params)
      catch e
        throw new TranslationError(name)

  ###
  添加翻译文件

  @param  {String}  locale        翻译所属语言
  @param  {Hash}    translation   翻译内容
  ###
  define = (locale, translation) ->
    target = messages[locale] or= {}
    $.extend true, target, translation
    return

  TranslationError: TranslationError
  translate: t: translate
  define: d: define
