import { View } from 'backbone.marionette'
import missing_tpl from "templates/common/missing.tpl"
import alert_tpl from 'templates/common/alert.tpl'

MissingView = View.extend {
  templateContext: ->
    {
      message: @options.message or "Cet item n'existe pas."
    }

  template: missing_tpl
}

AlertView = View.extend {
  template: alert_tpl
  className: ->
    return "alert alert-"+(@options.type or "danger")

  initialize: (options) ->
    options = options ? {};
    @title = options.title ? "Erreur !"
    @message = options.message ? "Erreur inconnue. Reessayez !"
    @type = options.type ? "danger"

  templateContext: ->
    return {
      title: @title
      message: @message
      dismiss: @options.dismiss is true
      type: @type
    }

}

export { MissingView, AlertView }
