app = require('app').app
Router = Backbone.Router.extend {
	routes: {
		"parties(/filter/criterion::criterion)": "list"
		"partie::id(/cle::cle)": "show"
		"partie/hash::hash": "showHash"
		"partie/start::id": "start"
	}

	list: (criterion) ->
		rank = app.Auth.get("rank")
		if (rank is "root") or (rank is "redacteur")
			require("apps/parties/list/controller.coffee").controller.listRedacteur(criterion)
		else if (rank is "joueur")
			require("apps/parties/list/controller.coffee").controller.listJoueur(criterion)

	show: (id, cle) ->
		rank = app.Auth.get("rank")
		if (rank is "joueur")
			require("apps/parties/show/controller.coffee").controller.show({id, cle})

	showHash: (hash) ->
		rank = app.Auth.get("rank")
		if rank is "off"
			cb = () ->
				app.trigger "partie:show:hash", hash
			require("apps/common/sign/sign_controller.coffee").controller.show({signin:true, showRedacCheck:false, callback:cb, showToggleButton:true })
		if rank is "joueur"
			require("apps/parties/show/controller.coffee").controller.show({hash})

	start: (id) ->
		rank = app.Auth.get("rank")
		if (rank is "joueur")
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

app.on "partie:show:hash", (hash) ->
	app.navigate "partie/hash:#{hash}"
	router.showHash(hash)
