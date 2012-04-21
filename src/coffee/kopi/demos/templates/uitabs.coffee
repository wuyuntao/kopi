define "kopi/demos/templates/uitabs", (require, exports, module) ->

  SimpleTemplate = require("kopi/ui/templates").SimpleTemplate

  # TODO Support i18n text
  tab1: new SimpleTemplate """
    <div class="kopi-inner">
      <h2>Tab #1</h2>
    </div> """

  tab2: new SimpleTemplate """
    <div class="kopi-inner">
      <h2>Tab #2</h2>
    </div> """

  tab3: new SimpleTemplate """
    <div class="kopi-inner">
      <h2>Tab #3</h2>
    </div> """

  tab4: new SimpleTemplate """
    <div class="kopi-inner">
      <h2>Tab #4</h2>
    </div> """

  tab5: new SimpleTemplate """
    <div class="kopi-inner">
      <h2>Tab #5</h2>
    </div> """

