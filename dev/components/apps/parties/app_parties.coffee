app = require('app').app
Router = Backbone.Router.extend {
	routes: {
		"parties(/filter/criterion::criterion)": "list"
		"partie::id(/cle::cle)": "show"
		"partie/start::id": "start"
	}

	list: (criterion) ->
		rank = app.Auth.get("rank")
		if (rank is "root") or (rank is "redacteur")
			app.Ariane.reset([{ text:"Parties", e:"parties:list", link:"parties"}])
			require("apps/parties/list/controller.coffee").controller.listRedacteur(criterion)
		else if (rank is "joueur")
			app.Ariane.reset([{ text:"Mes parties", e:"parties:list", link:"parties"}])
			require("apps/parties/list/controller.coffee").controller.listJoueur(criterion)

	show: (id, cle) ->
		rank = app.Auth.get("rank")
		if (rank is "joueur")
			app.Ariane.reset([{ text:"Mes parties", e:"parties:list", link:"parties"}])
			require("apps/parties/show/controller.coffee").controller.show(id, cle)

	start: (id) ->
		rank = app.Auth.get("rank")
		if (rank is "joueur")
			app.Ariane.reset([{ text:"Événements", e:"evenements:list", link:"Nouvelle partie"}])
			require("apps/parties/new/new_partie_controller.coffee").controller.show(id)
}

router = new Router()

app.on "parties:list", ()->
	app.navigate("parties")
	router.list()

app.on "parties:filter", (criterion) ->
	if criterion
		app.navigate "parties/filter/criterion:#{criterion}"
	else
		app.navigate "parties"

app.on "partie:start", (id) ->
	app.navigate "partie/start:#{id}"
	router.start(id)

app.on "partie:show", (id) ->
	app.navigate "partie:#{id}"
	router.show(id,"")

app.on "partie:show:cle", (id,cle) ->
	app.navigate "partie:#{id}/cle:#{cle}"
	router.show(id,cle)
