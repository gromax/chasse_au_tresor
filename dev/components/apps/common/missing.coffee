import Marionette from 'backbone.marionette'
import template from "templates/common/missing.tpl"

export default Marionette.View.extend {
	initialize: (options) ->
		options = options or {}
		@message = options.message or "Cet item n'existe pas."

	serializeData: ->
		{
			message: @message
		}

	template: template
}
