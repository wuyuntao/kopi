kopi.module("kopi.utils.text")
  .require("kopi")
  .define (exports, kopi) ->

    reUnderscore = /(?:^|[_-])(.)/
    reFirstLetter = /^(.)/
    ###
    把字符串转换成类名格式，参考 Rails 同名方法

    @param    {String}  word        要转换的字符串
    @param    {Boolean} upperCase   第一个字母是否大写
    @return   {String}
    ###
    camelize = (word, upperCase=true) ->
      word = ("" + word).replace(reUnderscore, (c) -> c.toUpperCase())
      unless upperCase
        word = word.replace(reFirstLetter, (c) -> c.toLowerCase())
      word

    ###
    将字符串转换成对象
    ###
    constantize = (name) -> kopi._build(name)

    ###
    是否为字符串
    ###
    # isString = (str) -> !!(str is '' or (str and str.charCodeAt and str.substr))

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
    exports.constantize = constantize
    exports.underscore = underscore
