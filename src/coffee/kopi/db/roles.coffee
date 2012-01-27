kopi.module("kopi.db.roles")
  .require("kopi.exceptions")
  .require("kopi.db.models")
  .require("kopi.utils.object")
  .define (exports, exceptions, models, object) ->

    ###
    The `Role` class is bound to exactly one model object during any given use case enactment

    Usage

      class Admin extends Role

        isAdmin: ->
          this.user.name == "admin"

      user = new User()
      admin = Admin.apply(user)
    ###
    class Role

      this.model = (model) -> this._modelClass = model

      this.apply = (model) -> new this(model)

      constructor: (model) -> this.model = model

    ###
    The `Context` class includes the roles for a given algorithm, scenario, or use case.

    Usage

      class DestroyBlog
        this.roles
          owner: Admin
          blog: Blog

        do: ->
          if this.owner.isAdmin()
            this.blog.destroy()

      context = new DestroyBlog owner: owner, blog: blog
      context.do()

    ###
    class Context

      this.roles = (roles={}) ->
        this._meta or= {}
        this._meta = object.extend {}, this._meta, roles

      constructor: (roles={}) ->
        cls = this.constructor
        meta = cls._meta or= {}
        for own name, role of roles
          if name of meta and role instanceof meta[name]
            this[name] = role
          else
            throw new exceptions.ValueError("Unknown role for #{cls.name}: ['#{name}', #{role}]")

    exports.Role = Role
    exports.Context = Context
