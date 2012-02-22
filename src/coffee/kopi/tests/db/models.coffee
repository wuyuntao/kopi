define "kopi/tests/db/models", (require, exports, module) ->

  q = require "qunit"
  fixtures = require "kopi/tests/db/fixtures"
  models = require "kopi/db/models"
  errors = require "kopi/db/errors"

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

  q.module "kopi.db.models"

  q.test "primary key", ->
    q.equals authorAlpha.pk(), 1

  q.test "fields", ->
    q.equals authorAlpha.id, 1
    q.equals authorAlpha.name, "Alpha"
    q.equals authorAlpha.email, "alpha@gmail.com"
    q.equals authorAlpha.registerAt.getTime(), new Date(2012, 2, 1, 20).getTime()

  q.test "set values for fields", ->
    authorTheta.name = "Iota"
    authorTheta.registerAt = new Date(2012, 2, 3, 14)

    q.equals authorTheta.name, "Iota"
    q.equals authorTheta.registerAt.getTime(), new Date(2012, 2, 3, 14).getTime()

  q.test "many-to-one relationship", ->
    q.equals blogZeta.ownerId, 1
    q.equals blogZeta.owner.id, 1
    q.equals blogZeta.owner.guid, authorAlpha.guid

  q.test "set values for many-to-one relationship", ->
    blogZeta.ownerId = authorTheta.id
    q.equals blogZeta.ownerId, 2
    getRelatedObject = ->
      q.equals blogZeta.owner.id, 2
      q.equals blogZeta.owner.guid, authorTheta.guid
    raises getRelatedObject, errors.RelatedModelNotFetched

    # Since ownerId is same as the id of prefetched owner
    blogZeta.owner = authorAlpha
    q.equals blogZeta.ownerId, 1
    q.equals blogZeta.owner.id, 1
    q.equals blogZeta.owner.guid, authorAlpha.guid

  q.test "one-to-many relationship", ->
    # Not supported yet
    # blogs = authorAlpha.blogs
    # q.equals blogs.length, 2
    # q.equals blogs[0].id, 1
    # q.equals blogs[1].id, 2

  q.test "set values for one-to-many relationship", ->

  q.test "many-to-many field", ->
    # Not supported yet
    # categories = articleDelta.categories
    # q.equals categories.length, 2
    # q.equals categories[0].id, 1
    # q.equals categories[0].name, "Beta"
    # q.equals categories[1].id, 2
    # q.equals categories[1].name, "Gamma"

    # articles = tagBeta.articles
    # q.equals articles.length, 2
    # q.equals articles[0].id, 1
    # q.equals articles[0].title, "Article Delta"
    # q.equals articles[1].id, 2
    # q.equals articles[1].name, "Article Epsilon"

  q.test "set values for many-to-many fields", ->
