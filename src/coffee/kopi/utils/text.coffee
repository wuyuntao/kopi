kopi.module("kopi.utils.text")
  .require("kopi")
  .define (exports, kopi) ->

    ###
    把字符串转换成类名格式，参考 Rails 同名方法

    @param    {String}  word        要转换的字符串
    @param    {Boolean} upperCase   第一个字母是否大写
    @return   {String}
    ###
    reUnderscore = /(?:^|[_-])(.)/
    reFirstLetter = /^(.)/
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
    把类名转换成小写的格式，参考 Rails 同名方法

    @param    {String}  word        要转换的字符串
    @param    {String}  symbol      单词之间的连接符
    @return   {String}
    ###
    underscore = (word, symbol='-') ->
      word
        .replace(/([A-Z]+)([A-Z][a-z\d])/g, "$1_$2")
        .replace(/([a-z\d])([A-Z])/g, "$1_$2")
        .replace(/[-_]/g, symbol)
        .toLowerCase()

    exports.camelize = camelize
    exports.constantize = constantize
    exports.underscore = underscore
