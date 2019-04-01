app = require('app').app
Router = Backbone.Router.extend {
	routes: {
		"joueurs(/filter/criterion::criterion)": "list"
		"joueur::id": "show"
		"joueur::id/edit": "edit"
		"joueur::id/password": "editPwd"
	}

	list: (criterion) ->
		rank = app.Auth.get("rank")
		if rank is "root"
			app.Ariane.reset([{ text:"Joueurs", e:"joueurs:list", link:"joueurs"}]);
			require("apps/joueurs/list/controller.coffee").controller.list(criterion)
}

router = new Router()

app.on "joueurs:list", ()->
	app.navigate("joueurs")
	router.list()

app.on "joueurs:filter", (criterion) ->
	if criterion
		app.navigate "joueurs/filter/criterion:#{criterion}"
	else
		app.navigate "joueurs"
