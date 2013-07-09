(function() {

  define("kopi/tests/db/models", function(require, exports, module) {
    var articleDelta, articleEpsilon, authorAlpha, authorTheta, blogEta, blogZeta, errors, fixtures, models, q, tagBeta, tagGamma;
    q = require("qunit");
    fixtures = require("kopi/tests/db/fixtures");
    models = require("kopi/db/models");
    errors = require("kopi/db/errors");
    authorAlpha = new fixtures.User({
      id: 1,
      name: "Alpha",
      email: "alpha@gmail.com",
      registerAt: new Date(2012, 2, 1, 20)
    });
    authorTheta = new fixtures.User({
      id: 2,
      name: "Theta",
      email: "theta@gmail.com",
      registerAt: new Date(2012, 2, 5, 10)
    });
    tagBeta = new fixtures.Tag({
      id: 1,
      name: "Beta"
    });
    tagGamma = new fixtures.Tag({
      id: 2,
      name: "Gamma"
    });
    articleDelta = new fixtures.Article({
      id: 1,
      title: "Article Delta",
      body: "Body of article delta",
      author: authorAlpha,
      publishedAt: new Date(2012, 2, 1, 20),
      updatedAt: new Date(2012, 2, 2, 10)
    });
    articleEpsilon = new fixtures.Article({
      id: 2,
      title: "Article Epsilon",
      body: "Body of article epsilon",
      author: authorAlpha,
      publishedAt: new Date(2012, 2, 2, 20),
      updatedAt: new Date(2012, 2, 3, 10)
    });
    blogZeta = new fixtures.Blog({
      id: 1,
      title: "Blog Zeta",
      owner: authorAlpha
    });
    blogEta = new fixtures.Blog({
      id: 2,
      title: "Blog Eta",
      owner: authorAlpha
    });
    q.module("kopi.db.models");
    q.test("primary key", function() {
      return q.equals(authorAlpha.pk(), 1);
    });
    q.test("fields", function() {
      q.equals(authorAlpha.id, 1);
      q.equals(authorAlpha.name, "Alpha");
      q.equals(authorAlpha.email, "alpha@gmail.com");
      return q.equals(authorAlpha.registerAt.getTime(), new Date(2012, 2, 1, 20).getTime());
    });
    q.test("set values for fields", function() {
      authorTheta.name = "Iota";
      authorTheta.registerAt = new Date(2012, 2, 3, 14);
      q.equals(authorTheta.name, "Iota");
      return q.equals(authorTheta.registerAt.getTime(), new Date(2012, 2, 3, 14).getTime());
    });
    q.test("many-to-one relationship", function() {
      q.equals(blogZeta.ownerId, 1);
      q.equals(blogZeta.owner.id, 1);
      return q.equals(blogZeta.owner.guid, authorAlpha.guid);
    });
    q.test("set values for many-to-one relationship", function() {
      var getRelatedObject;
      blogZeta.ownerId = authorTheta.id;
      q.equals(blogZeta.ownerId, 2);
      getRelatedObject = function() {
        q.equals(blogZeta.owner.id, 2);
        return q.equals(blogZeta.owner.guid, authorTheta.guid);
      };
      raises(getRelatedObject, errors.RelatedModelNotFetched);
      blogZeta.owner = authorAlpha;
      q.equals(blogZeta.ownerId, 1);
      q.equals(blogZeta.owner.id, 1);
      return q.equals(blogZeta.owner.guid, authorAlpha.guid);
    });
    q.test("one-to-many relationship", function() {});
    q.test("set values for one-to-many relationship", function() {});
    q.test("many-to-many field", function() {});
    return q.test("set values for many-to-many fields", function() {});
  });

}).call(this);
