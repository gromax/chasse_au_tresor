app = require('app').app

Router = Backbone.Router.extend {
	routes: {
		"" : "showHome"
		"home" : "showHome"
	}

	showHome: ->
		app.Ariane.reset []
		require("./show/show_controller.coffee").controller.showHome()

}

new Router()

app.on "home:show", ()->
	app.navigate("home")
	Router.showHome()
