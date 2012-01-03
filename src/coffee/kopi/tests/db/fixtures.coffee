kopi.module("kopi.tests.db.fixtures")
  .require("kopi.db.models")
  .define (exports, models) ->

    class User extends models.Model
      this.fields
        id:
          type: models.INTEGER
          primary: true
        name:
          type: models.STRING
        email:
          type: models.STRING
        registerAt:
          type: models.DATETIME

      this.hasMany "kopi.tests.db.fixtures.Blog"
      this.hasMany "kopi.tests.db.fixtures.Article"

    class Tag extends models.Model

      this.fields
        id:
          type: models.INTEGER
          primary: true
        name:
          type: models.STRING

      this.hasAndBelongsToMany "kopi.tests.db.fixtures.Article"

    class Article extends models.Model

      this.fields
        id:
          type: models.INTEGER
          primary: true
        title: models.STRING
        body:
          type: models.TEXT
        publishedAt:
          type: models.DATETIME
        updatedAt:
          type: models.DATETIME

      this.belongsTo "kopi.tests.db.fixtures.Blog"
      this.belongsTo User, name: "author"
      this.hasAndBelongsToMany Tag

    class Blog extends models.Model

      this.fields
        id:
          type: models.INTEGER
          primary: true
        title:
          type: models.STRING

      this.belongsTo User, name: "owner"
      this.hasMany Article

    exports.User = User
    exports.Tag = Tag
    exports.Article = Article
    exports.Blog = Blog
