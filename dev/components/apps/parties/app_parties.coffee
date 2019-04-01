app = require('app').app
Router = Backbone.Router.extend {
	routes: {
		"parties(/filter/criterion::criterion)": "list"
		"partie::id": "show"
	}

	list: (criterion) ->
		rank = app.Auth.get("rank")
		if (rank is "root") or (rank is "redacteur")
			app.Ariane.reset([{ text:"Parties", e:"parties:list", link:"parties"}]);
			require("apps/parties/list/controller.coffee").controller.list(criterion)
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
