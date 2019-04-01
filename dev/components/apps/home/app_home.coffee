app = require('app').app

Router = Backbone.Router.extend {
	routes: {
		"" : "showHome"
		"home" : "showHome"
		"login" : "showLogin"
	}

	showHome: ->
		app.Ariane.reset []
		require("./show/show_controller.coffee").controller.showHome()

	showLogin: ->
		if app.Auth.get("logged_in")
			app.Ariane.reset []
			require("./show/show_controller.coffee").controller.showHome()
		else
			app.Ariane.reset [{text:"Connexion", link:"login", e:"home:login"}]
			require("./login/login_controller.coffee").controller.showLogin()

	logout: ->
		if app.Auth.get("logged_in")
			closingSession = app.Auth.destroy()
			$.when(closingSession).done( (response)->
				# En cas d'échec de connexion, l'api server renvoie une erreur
				# Le delete n'occasione pas de raffraichissement des données
				# Il faut donc le faire manuellement
				app.Auth.refresh(response.logged)
				require("./show/show_controller.coffee").controller.showHome()
			).fail( (response)->
				alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/024]");
			)
}

router = new Router()

app.on "home:show", ()->
	app.navigate("home")
	router.showHome()

app.on "home:login", ()->
	app.navigate("login")
	router.showLogin()

app.on "home:logout", ()->
	router.logout()
	app.trigger("home:show")
