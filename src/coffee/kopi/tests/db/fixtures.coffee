kopi.module("kopi.tests.db.fixtures")
  .require("kopi.db.models")
  .define (exports, models) ->

    class User extends models.Model
      this.field "id",
        type: models.INTEGER
        primary: true
      this.field "name"
      this.field "email"
      this.field "registerAt",
        type: models.DATETIME

      this.hasMany "kopi.tests.db.fixtures.Blog"
      this.hasMany "kopi.tests.db.fixtures.Article"

    class Tag extends models.Model

      this.field "id",
          type: models.INTEGER
          primary: true
      this.field "name"

      this.hasMany "kopi.tests.db.fixtures.Article"

    class Article extends models.Model

      this.field "id",
        type: models.INTEGER
        primary: true
      this.field "title"
      this.field "body"
        type: models.TEXT
      this.field "publishedAt"
        type: models.DATETIME
      this.field "updatedAt"
        type: models.DATETIME

      this.belongsTo "kopi.tests.db.fixtures.Blog"
      this.belongsTo User, name: "author"
      this.hasMany Tag, name: "categories"

    class Blog extends models.Model

      this.field "id",
        type: models.INTEGER
        primary: true
      this.field "title",
        type: models.STRING

      this.belongsTo User, name: "owner"
      this.hasMany Article

    exports.User = User
    exports.Tag = Tag
    exports.Article = Article
    exports.Blog = Blog
