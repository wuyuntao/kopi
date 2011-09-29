###
模块

TODO 用 window.exports 作为顶级模块？
###
class Module

  # @type {RegExp}          模块名称的正则表达式
  reModuleName = /^([\w_]+\.)*[\w_]+$/

  ###
  生成模块对象

  @param  {String}  name    模块名称
  @param  {Boolean} auto    是否自动创建模块
  @return {Object}          模块
  ###
  this.build = (name, auto=true) ->
    module = window
    for item in name.split('.')
      if item of module
        unless module[item] instanceof this
          throw new Error("#{item} is not a module: #{name}")
        module = module[item]
      else if auto
        module = module[item] = new this(name)
      else
        throw new Error("Module #{item} does not exist: #{name}")
    module

  ###
  @param  {String}  name    模块名称
  ###
  constructor: (name) ->
    throw new Error("#{name} is not a valid module name") unless reModuleName.test(name)
    # @type   {String}      模块名称
    this.name = name
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
    throw new Error("#{name} is not a valid module name") unless reModuleName.test(name)
    this.requires.push(this.constructor.build(name, false)) if assignment
    this

  ###
  模块定义

  @param  {Function}  func     模块定义的回调方法
  @return {null}
  ###
  define: (func) ->
    # 模块不能重复定义
    delete this.require
    delete this.define
    if $.isFunction(func)
      func(this, this.requires...)
    else
      $.extend this, func
    return

###
声明模块

@param  {String}  name    模块名称
@return {Module}          模块
###
module = (name) -> Module.build(name)

###
定义 Kopi 模块
###
module("kopi").define module: module
