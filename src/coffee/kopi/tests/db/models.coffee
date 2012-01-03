kopi.module("kopi.tests.db.models")
  .require("kopi.tests.db.fixtures")
  .require("kopi.db.models")
  .define (exports, fixtures, models) ->

    authorAlpha = new fixtures.User
      id: 1
      name: "Alpha"
      email: "alpha@gmail.com"
      registerAt: new Date(2012, 2, 1, 20)

    authorTheta = new fixtures.User
      id: 2
      name: "Theta"
      email: "theta@gmail.com"
      registerAt: new Date(2012, 2, 5, 10)

    tagBeta = new fixtures.Tag
      id: 1
      name: "Beta"

    tagGamma = new fixtures.Tag
      id: 2
      name: "Gamma"

    articleDelta = new fixtures.Article
      id: 1
      title: "Article Delta"
      body: "Body of article delta"
      author: authorAlpha
      tags: [tagBeta, tagGamma]
      publishedAt: new Date(2012, 2, 1, 20)
      updatedAt: new Date(2012, 2, 2, 10)

    articleEpsilon = new fixtures.Article
      id: 2
      title: "Article Epsilon"
      body: "Body of article epsilon"
      author: authorAlpha
      publishedAt: new Date(2012, 2, 2, 20)
      updatedAt: new Date(2012, 2, 3, 10)

    articleEpsilon.tags.push(tagBeta)

    blogZeta = new fixtures.Blog
      id: 1
      title: "Blog Zeta"
      author: authorAlpha

    blogEta = new fixtures.Blog
      id: 2
      title: "Blog Eta"
      author: authorAlpha

    module "kopi.db.models"

    test "primary key", ->
      equals authorAlpha.pk(), 1

    test "fields", ->
      equals authorAlpha.id, 1
      equals authorAlpha.name, "Alpha"
      equals authorAlpha.email, "alpha@gmail.com"
      equals authorAlpha.registerAt, new Date(2012, 2, 1, 20)

    test "set values for fields", ->
      authorTheta.name = "Iota"
      authorTheta.registerAt = new Date(2012, 2, 3, 14)

      equals authorTheta.name, "Iota"
      equals authorTheta.registerAt, new Date(2012, 2, 3, 14)

    test "foreign fields", ->
      equals blogZeta.authorId, 1
      equals blogZeta.author.id, 1
      equals blogZeta.author.guid, authorAlpha.guid

    test "set values for foreign fields", ->
      blogZeta.authorId = authorTheta.id
      equals blogZeta.authorId, 2
      equals blogZeta.author.id, 2
      equals blogZeta.author.guid, authorTheta.guid

      blogZeta.author = authorAlpha
      equals blogZeta.authorId, 1
      equals blogZeta.author.id, 1
      equals blogZeta.author.guid, authorAlpha.guid

    test "reverse foreign fields", ->
      blogs = authorAlpha.blogs
      equals blogs.length, 2
      equals blogs[0].id, 1
      equals blogs[1].id, 2

    test "set values for reverse foreign fields", ->

    test "many-to-many field", ->
      tags = articleDelta.tags
      equals tags.length, 2
      equals tags[0].id, 1
      equals tags[0].name, "Beta"
      equals tags[1].id, 2
      equals tags[1].name, "Gamma"

      articles = tagBeta.articles
      equals articles.length, 2
      equals articles[0].id, 1
      equals articles[0].title, "Article Delta"
      equals articles[1].id, 2
      equals articles[1].name, "Article Epsilon"

    test "set values for many-to-many fields", ->
