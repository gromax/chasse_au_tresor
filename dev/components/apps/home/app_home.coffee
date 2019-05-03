app = require('app').app

Router = Backbone.Router.extend {
	routes: {
		"" : "showHome"
		"home" : "showHome"
		"login" : "showLogin"
		"signup" : "showSignUp"
	}

	showHome: ->
		require("./show/show_controller.coffee").controller.showHome()

	showLogin: ->
		if app.Auth.get("logged_in")
			require("./show/show_controller.coffee").controller.showHome()
		else
			require("./login/login_controller.coffee").controller.showLogin()

	showSignUp: ->
		if app.Auth.get("logged_in")
			require("./show/show_controller.coffee").controller.showHome()
		else
			require("./signup/signup_controller.coffee").controller.show()


	logout: ->
		if app.Auth.get("logged_in")
			closingSession = app.Auth.destroy()
			$.when(closingSession).done( (response)->
				# En cas d'échec de connexion, l'api server renvoie une erreur
				# Le delete n'occasione pas de raffraichissement des données
				# Il faut donc le faire manuellement
				app.Auth.refresh(response)
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

app.on "home:signup", ()->
	app.navigate("signin")
	router.showSignUp()

app.on "home:logout", ()->
	router.logout()
	app.trigger("home:show")
