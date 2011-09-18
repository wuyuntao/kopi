###
模块

TODO 每个模块直接用 Module 实例来表示，而不是用 Hash？
TODO 用 window.exports 作为顶级模块？
###
class Module

  # @type {RegExp}          模块名称的正则表达式
  reModuleName = /^([\w\-_]+\.)*[\w\-_]+$/
  ###
  生成模块对象

  @param  {String}  name    模块名称
  @return {Object}          模块
  ###
  build = (name) ->
    module = window
    module = module[item] or= {} for item in name.split('.')
    module

  ###
  @param  {String}  name    模块名称
  ###
  constructor: (name) ->
    throw new Error("Invalid module name") unless reModuleName.test(name)
    # @type {Object}        模块对象
    this.exports = build(name)
    # @type {Array}         依赖关系
    this.requires = []

  ###
  声明引入的模块

  TODO 动态加载依赖对象的脚本？

  @param  {String}  name        需要引入的模块名称
  @param  {Boolean} assignment  该模块是否需要被赋值
  @return {Module}              模块对象
  ###
  require: (name, assignment=true) ->
    throw new Error("Invalid module name") unless reModuleName.test(name)
    this.requires.push(build(name)) if assignment
    this

  ###
  模块定义

  @param  {Function}  func     模块定义的回调方法
  @return {null}
  ###
  define: (func) ->
    if $.isFunction(func)
      func(this.exports, this.requires...)
    else
      $.extend this.exports, func
    return

###
声明模块

@param  {String}  name    模块名称
@return {Module}          模块
###
module = (name) -> new Module(name)

###
定义 Kopi 模块
###
module("kopi").define module: module
