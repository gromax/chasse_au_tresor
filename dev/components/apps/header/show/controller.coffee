import { HeaderView } from "apps/header/show/view.coffee"

export controller = {
	show: () ->
		app = require('app').app
		if app.Auth
			navbar = new HeaderView() # Requiert le app.Auth
			app.regions.getRegion('header').show(navbar)
			navbar.listenTo(
				app.Auth,
				"change",
				()-> @logChange()
			)
			navbar.listenTo(app,"header:loading", navbar.spin)
		else
			console.log "Erreur : Objet session non défini !"
}
