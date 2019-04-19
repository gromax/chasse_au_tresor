import Marionette from 'backbone.marionette'
import template from 'templates/home/show/off.tpl'

app = require('app').app
export default Marionette.View.extend {
	template: template
	triggers: {
		"click a.js-login": "home:login"
		"click a.js-signup": "home:signup"
	},

	onHomeLogin: (e) ->
		app.trigger("home:login");

	onHomeSignup: (e) ->
		app.trigger("home:signup");


	templateContext: ->
		{
			version: app.version
		}
}
