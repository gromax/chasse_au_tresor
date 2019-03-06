import Marionette from 'backbone.marionette'
import template from 'templates/home/show/off.jst';

app = require('app').app
export default Marionette.Application.extend {
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
