import Marionette from 'backbone.marionette'
import OffView from 'apps/home/show/off_view.coffee'
import RootView from 'apps/home/show/root_view.coffee'
import RedacteurView from 'apps/home/show/redacteur_view.coffee'
import WorkInProgress from 'apps/common/workInProgress_view.coffee'

app = require('app').app
Controller = Marionette.Object.extend {
	channelName: "entities"
	showHome: ->
		rank = app.Auth.get("rank")
		switch rank
			when "root"
				view = new RootView()
			when "redacteur"
				view = new RedacteurView()
			when "joueur"
				view = new WorkInProgress()
			else
				view = new OffView()
		app.regions.getRegion('main').show(view)
}

export controller = new Controller()
