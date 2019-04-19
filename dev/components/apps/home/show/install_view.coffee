import Marionette from 'backbone.marionette'
import template from 'templates/home/show/install.tpl'

app = require('app').app
export default Marionette.View.extend {
	template: template
	triggers: {
		"click a.js-login": "home:login"
	},
	onHomeLogin: (e) ->
		app.trigger("home:login");
	serializeData: () ->
		{
			version: app.version
		}
}
