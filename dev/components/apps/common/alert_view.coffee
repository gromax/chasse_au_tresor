import Marionette from 'backbone.marionette'
import template from 'templates/common/alert.tpl'

export default Marionette.View.extend {
	template: template
	className: ->
		return "alert alert-"+(@options.type or "danger")

	initialize: (options) ->
		options = options ? {};
		@title = options.title ? "Erreur !"
		@message = options.message ? "Erreur inconnue. Reessayez !"
		@type = options.type ? "danger"

	serializeData: ->
		return {
			title: @title
			message: @message
			dismiss: @options.dismiss is true
			type: @type
		}

}
