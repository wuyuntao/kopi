define "kopi/utils/text", (require, exports, module) ->

  StringProto = String.prototype

  reUnderscore = /(?:^|[_-])(.)/
  reFirstLetter = /^(.)/
  upperCaseFn = (c) -> c.toUpperCase(c)
  lowerCaseFn = (c) -> c.toLowerCase(c)
  ###
  Convert string to UpperCamelCase.
  If `upperCase` is set to true, produce lowerCamelCase

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
  Try to find a constant with the name specified

  @param  {String}  name
  @param  {Object}  scope
  ###
  constantize = (name, scope=window) ->
    scope = scope[item] for item in name.split '.'
    scope

  ###
  If value in the string
  ###
  contains = (string, sub) -> string.indexOf(sub) >= 0

  ###
  Simple text template

  @param  {String}  string
  @param  {Hash}    params
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
  Remove leading and trailing white spaces from string
  ###
  # Ref:
  #   http://perfectionkills.com/whitespace-deviations/
  whitespaces = [
    '\\s',
    #'0009', # 'HORIZONTAL TAB'
    #'000A', # 'LINE FEED OR NEW LINE'
    #'000B', # 'VERTICAL TAB'
    #'000C', # 'FORM FEED'
    #'000D', # 'CARRIAGE RETURN'
    #'0020', # 'SPACE'

    '00A0',  # 'NO-BREAK SPACE'
    '1680',  # 'OGHAM SPACE MARK'
    '180E',  # 'MONGOLIAN VOWEL SEPARATOR'

    '2000-\\u200A',
    #'2000', # 'EN QUAD'
    #'2001', # 'EM QUAD'
    #'2002', # 'EN SPACE'
    #'2003', # 'EM SPACE'
    #'2004', # 'THREE-PER-EM SPACE'
    #'2005', # 'FOUR-PER-EM SPACE'
    #'2006', # 'SIX-PER-EM SPACE'
    #'2007', # 'FIGURE SPACE'
    #'2008', # 'PUNCTUATION SPACE'
    #'2009', # 'THIN SPACE'
    #'200A', # 'HAIR SPACE'

    '200B',  # 'ZERO WIDTH SPACE (category Cf)
    '2028',  # 'LINE SEPARATOR'
    '2029',  # 'PARAGRAPH SEPARATOR'
    '202F',  # 'NARROW NO-BREAK SPACE'
    '205F',  # 'MEDIUM MATHEMATICAL SPACE'
    '3000'   # 'IDEOGRAPHIC SPACE'
  ].join('\\u')
  if StringProto.trim
    trim = (string) ->
      StringProto.trim.call(string)
  else
    reLeading = new RegExp("^[#{whiteSpaces}]+")
    reTrailing = new RegExp("[#{whiteSpaces}]+$")
    trim = (string) ->
      string.replace(reLeading, "").replace(reTrailing, "")

  isWhitespace = (string) -> !trim(string)

  ###
  限定字符串长度
  ###
  truncate = (text, length) ->
    if text and text.length > length then text.substr(0, length - 3) + "..." else text

  reUpper = /([A-Z]+)([A-Z][a-z\d])/g
  reLower = /([a-z\d])([A-Z])/g
  reSymbol = /[-_\.]+/g
  strUnderscore = "$1_$2"
  strSymbol = "_"
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

  strDash = '-'
  dasherize = (word) ->
    underscore(word, strDash)

  camelize: camelize
  capitalize: capitalize
  constantize: constantize
  contains: contains
  format: format
  isString: isString
  pluralize: pluralize
  startsWith: startsWith
  endsWith: endsWith
  trim: trim
  isWhitespace: isWhitespace
  truncate: truncate
  underscore: underscore
  dasherize: dasherize
