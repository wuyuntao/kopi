kopi.module("kopi.tests.db.models")
  .require("kopi.tests.db.fixtures")
  .require("kopi.db.models")
  .require("kopi.db.errors")
  .define (exports, fixtures, models, errors) ->

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
      publishedAt: new Date(2012, 2, 1, 20)
      updatedAt: new Date(2012, 2, 2, 10)
      # Not supported yet
      # categories: [tagBeta, tagGamma]

    articleEpsilon = new fixtures.Article
      id: 2
      title: "Article Epsilon"
      body: "Body of article epsilon"
      author: authorAlpha
      publishedAt: new Date(2012, 2, 2, 20)
      updatedAt: new Date(2012, 2, 3, 10)

    # Not supported yet
    # articleEpsilon.categories.push(tagBeta)

    blogZeta = new fixtures.Blog
      id: 1
      title: "Blog Zeta"
      owner: authorAlpha

    blogEta = new fixtures.Blog
      id: 2
      title: "Blog Eta"
      owner: authorAlpha

    module "kopi.db.models"

    test "primary key", ->
      equals authorAlpha.pk(), 1

    test "fields", ->
      equals authorAlpha.id, 1
      equals authorAlpha.name, "Alpha"
      equals authorAlpha.email, "alpha@gmail.com"
      equals authorAlpha.registerAt.getTime(), new Date(2012, 2, 1, 20).getTime()

    test "set values for fields", ->
      authorTheta.name = "Iota"
      authorTheta.registerAt = new Date(2012, 2, 3, 14)

      equals authorTheta.name, "Iota"
      equals authorTheta.registerAt.getTime(), new Date(2012, 2, 3, 14).getTime()

    test "many-to-one relationship", ->
      equals blogZeta.ownerId, 1
      equals blogZeta.owner.id, 1
      equals blogZeta.owner.guid, authorAlpha.guid

    test "set values for many-to-one relationship", ->
      blogZeta.ownerId = authorTheta.id
      equals blogZeta.ownerId, 2
      getRelatedObject = ->
        equals blogZeta.owner.id, 2
        equals blogZeta.owner.guid, authorTheta.guid
      raises getRelatedObject, errors.RelatedModelNotFetched

      # Since ownerId is same as the id of prefetched owner
      blogZeta.owner = authorAlpha
      equals blogZeta.ownerId, 1
      equals blogZeta.owner.id, 1
      equals blogZeta.owner.guid, authorAlpha.guid

    test "one-to-many relationship", ->
      # Not supported yet
      # blogs = authorAlpha.blogs
      # equals blogs.length, 2
      # equals blogs[0].id, 1
      # equals blogs[1].id, 2

    test "set values for one-to-many relationship", ->

    test "many-to-many field", ->
      # Not supported yet
      # categories = articleDelta.categories
      # equals categories.length, 2
      # equals categories[0].id, 1
      # equals categories[0].name, "Beta"
      # equals categories[1].id, 2
      # equals categories[1].name, "Gamma"

      # articles = tagBeta.articles
      # equals articles.length, 2
      # equals articles[0].id, 1
      # equals articles[0].title, "Article Delta"
      # equals articles[1].id, 2
      # equals articles[1].name, "Article Epsilon"

    test "set values for many-to-many fields", ->
