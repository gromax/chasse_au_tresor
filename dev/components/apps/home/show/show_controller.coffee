import Marionette from 'backbone.marionette'
import { AlertView } from 'apps/common/commons_view.coffee'
import OffView from 'apps/home/show/off_view.coffee'
import RootView from 'apps/home/show/root_view.coffee'
import RedacteurView from 'apps/home/show/redacteur_view.coffee'
import WorkInProgress from 'apps/common/workInProgress_view.coffee'
import JoueurView from 'apps/home/show/joueur_view.coffee'

app = require('app').app
Controller = Marionette.Object.extend {
	channelName: "entities"
	showHome: ->
		rank = app.Auth.get("rank")
		switch rank
			when "root"
				app.regions.getRegion('main').show(new RootView())
			when "redacteur"
				app.regions.getRegion('main').show(new RedacteurView())
			when "joueur"
				app.regions.getRegion('main').show(new JoueurView())
			else
				app.regions.getRegion('main').show(new OffView())

}

export controller = new Controller()
