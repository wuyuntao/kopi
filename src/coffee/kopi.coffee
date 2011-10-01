###
模块
###
class Module

  # @type {RegExp}          模块名称的正则表达式
  reModuleName = /^([\w_]+\.)*[\w_]+$/

  # @type {Hash}            模块名对应的 js 文件地址
  scripts = {
    # 'kopi': '/js/kopi.js'
    # 'kopi.utils': '/js/kopi/utils.js'
    # 'kopi.utils.i18n': '/js/kopi/utils/i18n.js'
    # ...
    # 一个 Minified JS 可以包括所有的 JS
    # 'kopi': '/js/kopi.all.js'
    # 'kopi.utils': '/js/kopi.all.js'
    # 'kopi.utils.i18n': '/js/kopi.all.js'
    # ...
  }

  ###
  加载脚本

  @param  {String}  src         脚本地址
  @param  {Boolean} async       是否为异步加载
  ###
  loadScript = (src, async=true) ->
    throw new Error("Not implemented yet")

  ###
  生成模块对象

  @param  {String}  name        模块名称
  @param  {Boolean} autoCreate  是否自动创建模块
  @param  {Boolean} autoLoad    是否自动加载模块
  @return {Object}              模块
  ###
  this.build = (name, autoCreate=true, autoLoad=false) ->
    module = window
    for item in name.split('.')
      if item of module
        unless module[item] instanceof this
          throw new Error("#{item} is not a module: #{name}")
        module = module[item]
      else if autoCreate
        module = module[item] = new this(name)
      else if autoLoad
        throw new Error("Module #{item} does not exist: #{name}")
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
