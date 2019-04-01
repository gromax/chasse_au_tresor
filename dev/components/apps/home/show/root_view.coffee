import Marionette from 'backbone.marionette'
import template from 'templates/home/show/root.tpl'

app = require('app').app
export default Marionette.Application.extend {
	template: template
	triggers: {
		"click a.js-redacteurs": "redacteurs:list"
		"click a.js-evenements": "evenements:list"
		"click a.js-joueurs": "joueurs:list"
		"click a.js-parties": "parties:list"
	}

	onRedacteursList: (e) ->
		app.trigger "redacteurs:list"

	onEvenementsList: (e) ->
		app.trigger "evenements:list"

	onJoueursList: (e) ->
		app.trigger "joueurs:list"

	onPartiesList: (e) ->
		app.trigger "parties:list"

}
