kopi.module("kopi.utils.text")
  .define (exports) ->

    reUnderscore = /(?:^|[_-])(.)/
    reFirstLetter = /^(.)/
    upperCaseFn = (c) -> c.toUpperCase(c)
    lowerCaseFn = (c) -> c.toLowerCase(c)
    ###
    把字符串转换成类名格式，参考 Rails 同名方法

    @param    {String}  word        要转换的字符串
    @param    {Boolean} upperCase   第一个字母是否大写
    @return   {String}
    ###
    camelize = (word, upperCase=true) ->
      word = ("" + word).replace(reUnderscore, upperCaseFn)
      unless upperCase
        word = word.replace(reFirstLetter, lowerCaseFn)
      word

    ###
    Convert a copy of string which first letter capitalized
    ###
    capitalize = (word) ->
      word.replace(reFirstLetter, upperCaseFn)

    ###
    将字符串转换成对象

    @param  {String}  name
    @param  {Object}  scope
    ###
    constantize = (name, scope=window) ->
      scope = scope[item] for item in name.split '.'
      scope

    ###
    字符串是否包含某些字符
    ###
    contains = (string, sub) -> string.indexOf(sub) >= 0

    ###
    格式化字符串

    @param  {String}  string      待格式化的字符串
    @param  {Hash}    params      格式化字符串的参数
    ###
    format = (string, params) ->
      return string unless params
      for name, value of params
        string = string.replace(new RegExp("\{#{name}\}", 'gi'), value)
      string

    # Is the given value a string?
    isString = (string) ->
      !!(string is '' or (string and string.charCodeAt and string.substr))

    ###
    Return plural form of given lowercase singular word (English only). Based on
    ActiveState recipe http://code.activestate.com/recipes/413172/
    ###
    ABERRANT_PLURAL_MAP =
      appendix: 'appendices'
      barracks: 'barracks'
      cactus: 'cacti'
      child: 'children'
      criterion: 'criteria'
      deer: 'deer'
      echo: 'echoes'
      elf: 'elves'
      embargo: 'embargoes'
      focus: 'foci'
      fungus: 'fungi'
      goose: 'geese'
      hero: 'heroes'
      hoof: 'hooves'
      index: 'indices'
      knife: 'knives'
      leaf: 'leaves'
      life: 'lives'
      man: 'men'
      mouse: 'mice'
      nucleus: 'nuclei'
      person: 'people'
      phenomenon: 'phenomena'
      potato: 'potatoes'
      self: 'selves'
      syllabus: 'syllabi'
      tomato: 'tomatoes'
      torpedo: 'torpedoes'
      veto: 'vetoes'
      woman: 'women'
    VOWELS = ['a', 'e', 'i', 'o', 'u']

    pluralize = (singular) ->
      return '' if not singular
      plural = ABERRANT_PLURAL_MAP[singular]
      return plural if plural

      root = singular
      len = singular.length
      try
        if singular[len-1] == 'y' and singular[len-2] not in VOWELS
          root = singular[0...(len-1)]
          suffix = 'ies'
        else if singular[len-1] == 's'
          if singular[len-2] in VOWELS
            if singular[len-3...len] == 'ius'
              root = singular[0...len-2]
              suffix = 'i'
            else
              root = singular[0...len-1]
              suffix = 'ses'
          else
            suffix = 'es'
        else if singular[len-2...len] in ['ch', 'sh']
          suffix = 'es'
        else
          suffix = 's'
      catch e
        suffix = 's'
      plural = root + suffix
      return plural

    ###
    Prefix checker
    ###
    startsWith = (string, prefix) ->
      string.lastIndexOf(prefix, 0) == 0

    ###
    Suffix checker
    ###
    endsWith = (string, suffix) ->
      len = string.length - suffix.length
      len >= 0 and string.indexOf(suffix, len) == len

    ###
    是否为字符串
    ###
    # isString = (str) -> !!(str is '' or (str and str.charCodeAt and str.substr))

    ###
    限定字符串长度
    ###
    truncate = (text, length) ->
      if text and text.length > length then text.substr(0, length - 3) + "..." else text

    reUpper = /([A-Z]+)([A-Z][a-z\d])/g
    reLower = /([a-z\d])([A-Z])/g
    reSymbol = /[-_\.]+/g
    strUnderscore = "$1_$2"
    strSymbol = "-"
    ###
    把类名转换成小写的格式，参考 Rails 同名方法

    @param    {String}  word        要转换的字符串
    @param    {String}  symbol      单词之间的连接符
    @return   {String}
    ###
    underscore = (word, symbol=strSymbol) ->
      word
        .replace(reUpper, strUnderscore)
        .replace(reLower, strUnderscore)
        .replace(reSymbol, symbol)
        .toLowerCase()

    exports.camelize = camelize
    exports.capitalize = capitalize
    exports.constantize = constantize
    exports.contains = contains
    exports.format = format
    exports.isString = isString
    exports.pluralize = pluralize
    exports.startsWith = startsWith
    exports.endsWith = endsWith
    exports.truncate = truncate
    exports.underscore = underscore
