import Marionette from 'backbone.marionette'
import OffView from 'apps/home/show/off_view.coffee'

app = require('app').app
Controller = Marionette.Object.extend {
	channelName: "entities"
	showHome: ->
		view = new OffView()
		app.regions.getRegion('main').show(view)
}

export controller = new Controller()
