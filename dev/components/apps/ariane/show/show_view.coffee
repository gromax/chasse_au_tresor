import Marionette from 'backbone.marionette'
import showNoViewTemplate from 'templates/ariane/show/show-noview.jst'
import showItemTemplate from 'templates/ariane/show/show-item.jst'
import showListTemplate from 'templates/ariane/show/show-list.jst'


app = require('app').app

noView = Marionette.View.extend {
	tagName: "li"
	className: "breadcrumb-item active"
	template: showNoViewTemplate
}

Item = Marionette.View.extend {
	tagName: "li"

	className: ->
		if @model.get("active")
			"breadcrumb-item"
		else
			# Ça peut paraître bizarre, mais c'est quand il n'y a pas de lien
			# et que c'est inactif qu'il faut mettre la classe active avec bootstrap breadcrumb
			"breadcrumb-item active"

	initialize: ->
		@listenTo(
			@model,
			"change:active",
			()->
				@render()
		)

	template: showItemTemplate
	triggers: {
		"click a.js-next" : "ariane:next"
		"click a.js-prev" : "ariane:prev"
		"click a.js-link" : "ariane:navigate"
	}

	onArianePrev: ->
		event_name = @model.get("e")
		data = @model.get("prev")
		app.trigger.apply(app,_.flatten([event_name,data]))

	onArianeNext: ->
		event_name = @model.get("e")
		data = @model.get("next")
		app.trigger.apply(app,_.flatten([event_name,data]))

	onArianeNavigate: ->
		active = @model.get("active")
		event_name = @model.get("e")
		data = @model.get("data")
		if active and event_name
			app.trigger.apply(app,_.flatten([event_name,data]))
}

CollectionView = Marionette.CollectionView.extend {
	tagName:"ol"
	className: "breadcrumb"
	childView:Item
	emptyView:noView
}

export default Marionette.View.extend {
	tagName: "nav"
	template: showListTemplate
	regions: {
		body: {
			el:'ol'
			replaceElement:true
		}
	}

	onRender: ->
		@subCollection = new CollectionView {
			collection: @collection
		}
		@showChildView('body', @subCollection)
}

