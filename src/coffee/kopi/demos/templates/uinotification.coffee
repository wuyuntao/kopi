define "kopi/demos/templates/uinotification", (require, exports, module) ->

  SimpleTemplate = require("kopi/ui/templates").SimpleTemplate

  notification: new SimpleTemplate """
    <div class="kopi-inner">
      <h2>Indicator</h2>
      <p>Description</p>
      <div class="indicator-section">
      </div>
      <h2>Bubble</h2>
      <p>Description</p>
      <div class="bubble-section">
      </div>
      <h2>Dialog</h2>
      <p>Description</p>
      <div class="dialog-section">
      </div>
    </div>
  """
