define "kopi/demos/templates/uibuttons", (require, exports, module) ->

  SimpleTemplate = require("kopi/ui/templates").SimpleTemplate

  # TODO Support i18n text
  buttons: new SimpleTemplate """
    <div>
      <h2>Buttons</h2>
      <p>Description</p>
      <div class="button-style-section">
      </div>
      <h2>Buttons</h2>
      <p>Description</p>
      <div class="button-size-section">
      </div>
    </div> """
