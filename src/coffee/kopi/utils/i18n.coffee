define "kopi/utils/i18n", (require, exports, module) ->

  $ = require "jquery"
  exceptions = require "kopi/exceptions"
  settings = require "kopi/settings"
  utils = require "kopi/utils"
  text = require "kopi/utils/text"
  set = require "kopi/utils/structs/set"

  # @type {Array}             All languages we support
  locales = new set.Set(["en", "zh_CN"])
  # @type {Hash}              Contains all translations
  messages = {}

  ###
  Error raised when transition can not be found
  ###
  class TranslationError extends exceptions.Exception
    constructor: (name) ->
      super("Missing translation \"#{name}\", [#{settings.kopi.i18n.locale}, #{settings.kopi.i18n.fallback}]")

  ###
  Lookup text translation

  @param  {String}  name
  @param  {Hash}    params
  ###
  translate = (name, params) ->
    try
      return text.format(text.constantize(name, messages[settings.kopi.i18n.locale]), params)
    catch e
      try
        return text.format(text.constantize(name, messages[settings.kopi.i18n.fallback]), params)
      catch e
        return params.missing if params and params.missing
        throw new TranslationError(name)

  ###
  Define text translation

  @param  {String}  locale
  @param  {Hash}    translation
  ###
  define = (locale, translation) ->
    locales.add(locale)
    target = messages[locale] or= {}
    $.extend true, target, translation
    return

  TranslationError: TranslationError
  translate: translate
  t: translate
  define: define
  d: define
