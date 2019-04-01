import Marionette from "backbone.marionette"
import LoginView from "apps/home/login/login_view.coffee"

app = require("app").app

Controller = Marionette.Object.extend {
	channelName: "entities"
	showLogin: ->
		that = @
		view = new LoginView({ generateTitle: true })
		view.on "form:submit", (data) ->
			openingSession = app.Auth.save(data)
			if openingSession
				app.trigger("header:loading", true)
				# En cas d'échec de connexion, l'api server renvoie une erreur
				$.when(openingSession).done( (response)->
					app.trigger("home:show");
				).fail( (response)->
					if response.status is 422
						view.triggerMethod("form:data:invalid", response.responseJSON.ajaxMessages);
					else
						alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/025]")
				).always( ()->
					app.trigger("header:loading", false)
				)
			else
				view.triggerMethod("form:data:invalid", app.Auth.validationError)

		app.regions.getRegion('main').show(view);
}

export controller = new Controller()
