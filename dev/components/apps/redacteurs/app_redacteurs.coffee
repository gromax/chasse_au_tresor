app = require('app').app
Router = Backbone.Router.extend {
	routes: {
		"redacteurs(/filter/criterion::criterion)": "list"
		"redacteur::id": "show"
		"redacteur::id/edit": "edit"
		"redacteur::id/password": "editPwd"
	}

	list: (criterion) ->
		rank = app.Auth.get("rank")
		if rank is "root"
			require("apps/redacteurs/list/controller.coffee").controller.list(criterion)
}

router = new Router()

app.on "redacteurs:list", ()->
	app.navigate("redacteurs")
	router.list()

app.on "redacteurs:filter", (criterion) ->
	if criterion
		app.navigate "redacteurs/filter/criterion:#{criterion}"
	else
		app.navigate "redacteurs"
