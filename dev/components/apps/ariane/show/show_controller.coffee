import ArianeView from 'apps/ariane/show/show_view.coffee'

app = require('app').app

export controller = {
	showAriane: ->
		if app.Ariane
			view = new ArianeView { collection: app.Ariane.collection }
			app.regions.getRegion('ariane').show(view)
		else
			console.log "L'objet fil d'ariane n'est pas initialisé."
}
