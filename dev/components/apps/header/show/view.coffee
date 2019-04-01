import Marionette from 'backbone.marionette'
import template from 'templates/header/show/header-navbar.tpl'

app = require('app').app
export default Marionette.View.extend {
	template: template
	triggers: {
		"click a.js-home": "home:show"
		"click a.js-edit-me": "home:editme"
		"click a.js-login": "home:login"
		"click a.js-logout": "home:logout"
	}

	initialize: (options) ->
		options = options ? {};
		@auth = _.clone(app.Auth.attributes)

	serializeData: () ->
		isOff = not @auth.logged_in
		{
			isOff: isOff
			nom: if isOff then "Déconnecté" else @auth.nom
			version: app.version
		}

	logChange: () ->
		@initialize()
		@render()

	onHomeShow: (e) ->
		app.trigger("home:show")

	onHomeEditme: (e) ->
		app.trigger("user:show",app.Auth.get("id"))

	onHomeLogin: (e) ->
		app.trigger("home:login")

	onHomeLogout: (e) ->
		app.trigger("home:logout")

	spin: (set_on) ->
		if (set_on)
			$("span.js-spinner", @$el).html("<i class='fa fa-spinner fa-spin'></i>")
		else
			$("span.js-spinner", @$el).html("")
}


