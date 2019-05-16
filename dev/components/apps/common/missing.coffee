import Marionette from 'backbone.marionette'
import template from "templates/common/missing.tpl"

export default Marionette.View.extend {
  templateContext: ->
    {
      message: @options.message or "Cet item n'existe pas."
    }

  template: template
}
