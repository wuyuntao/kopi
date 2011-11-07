kopi.module("kopi.tests.ui.text")
  .require("kopi.ui.text")
  .define (exports, text) ->

    SHORT_TEXT = "The Zen of Python, by Tim Peters"
    LONG_TEXT = """Beautiful is better than ugly.
      Explicit is better than implicit.
      Simple is better than complex.
      Complex is better than complicated.
      Flat is better than nested.
      Sparse is better than dense.
      Readability counts.
      Special cases aren't special enough to break the rules.
      Although practicality beats purity.
      Errors should never pass silently.
      Unless explicitly silenced.
      In the face of ambiguity, refuse the temptation to guess.
      There should be one-- and preferably only one --obvious way to do it.
      Although that way may not be obvious at first unless you're Dutch.
      Now is better than never.
      Although never is often better than *right* now.
      If the implementation is hard to explain, it's a bad idea.
      If the implementation is easy to explain, it may be a good idea.
      Namespaces are one honking great idea -- let's do more of those!"""

    $ ->

      module "kopi.ui.text"

      test "ellipsis short text", ->
        ellipsisText = new text.EllipsisText("#ellipsis-short-text")
        ellipsisText.text(SHORT_TEXT)
        ellipsisText.skeleton()
        ellipsisText.render()

      test "ellipsis long text", ->
        ellipsisText = new text.EllipsisText("#ellipsis-long-text")
        ellipsisText.text(LONG_TEXT)
        ellipsisText.skeleton()
        ellipsisText.render()
