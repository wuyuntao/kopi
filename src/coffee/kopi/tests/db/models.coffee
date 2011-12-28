kopi.module("kopi.tests.db.models")
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

      this.hasOne "kopi.tests.db.models.Blog"
      this.hasMany "kopi.tests.db.models.Post"

    class Tag extends models.Model

      this.fields
        id:
          type: models.INTEGER
          primary: true
        name:
          type: models.STRING

      this.hasAndBelongsToMany "kopi.tests.db.models.Post"

    class Post extends models.Model

      this.fields
        id:
          type: models.INTEGER
          primary: true
        title:
          type: models.STRING
        body:
          type: models.TEXT
        publishedAt:
          type: models.DATETIME
        updatedAt:
          type: models.DATETIME

      this.belongsTo "kopi.tests.db.models.Blog"
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
      this.hasMany Post

    exports.User = User
    exports.Post = Post
    exports.Tag = Tag
    exports.Blog = Blog

    author = new User
      id: 1
      name: "Alpha"
      email: "alpha@beta.com"

    firstPost = new Post
      id: 1
      title: "First post"
      body: "Body of first post"
      author: author

    secondPost = new Post
      id: 2
      title: "Second post"
      body: "Body of second post"
      author: author

    blog = new Blog
      id: 1
      title: "Gamma Blog"
      author: author

    module "kopi.db.models"

    test "primary key", ->

    test "fields", ->

    test "foreign field", ->

    test "many to many field", ->
