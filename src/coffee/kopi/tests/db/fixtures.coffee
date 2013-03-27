define "kopi/tests/db/fixtures", (require, exports, module) ->

  models = require "kopi/db/models"

  class User extends models.Model
    this.field "id",
      type: models.INTEGER
      primary: true
    this.field "name"
    this.field "email"
    this.field "registerAt",
      type: models.DATETIME

    this.hasMany "Blog", module: "kopi/tests/db/fixtures"
    this.hasMany "Article", module: "kopi/tests/db/fixtures"

    this.index "name"
    this.index "email"
    this.index "registerAt"

  class Tag extends models.Model

    this.field "id",
        type: models.INTEGER
        primary: true
    this.field "name"

    this.hasMany "Article", module: "kopi/tests/db/fixtures"

    this.index "name"

  class Article extends models.Model

    this.field "id",
      type: models.INTEGER
      primary: true
    this.field "title"
    this.field "body",
      type: models.TEXT
    this.field "publishedAt",
      type: models.DATETIME
    this.field "updatedAt",
      type: models.DATETIME

    this.belongsTo "Blog", module: "kopi/tests/db/fixtures"
    this.belongsTo User, name: "author"
    this.hasMany Tag, name: "categories"

    this.index "title"

  class Blog extends models.Model

    this.field "id",
      type: models.INTEGER
      primary: true
    this.field "title",
      type: models.STRING

    this.index "title"

  Article.belongsTo Blog

  User: User
  Tag: Tag
  Article: Article
  Blog: Blog
