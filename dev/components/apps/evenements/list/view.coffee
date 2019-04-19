import Marionette from 'backbone.marionette'
import templateList from 'templates/evenements/list/redacteur_list.tpl'
import templateRedacteurItem from 'templates/evenements/list/redacteur_item.tpl'
import templateRedacteurNone from 'templates/evenements/list/redacteur_none.tpl'
import template from 'templates/evenements/list/panel.tpl'

import templateJoueurItem from 'templates/evenements/list/joueur_item.tpl'
import templateJoueurNone from 'templates/evenements/list/joueur_none.tpl'



app = require('app').app

RedacteurNoView = Marionette.View.extend {
	template: templateRedacteurNone
	tagName: "tr"
	className: "alert"
}

RedacteurItemView = Marionette.View.extend {
	tagName: "tr"
	template: templateRedacteurItem
	triggers: {
		"click td a.js-edit": "edit"
		"click button.js-delete": "delete"
		"click button.js-actif": "activation:toggle"
		"click button.js-visible": "visible:toggle"
		"click": "show"
	}

	flash: (cssClass)->
		$view = @$el
		$view.hide().toggleClass("table-"+cssClass).fadeIn(800, ()->
			setTimeout( ()->
				$view.toggleClass("table-"+cssClass)
			, 500)
		)

	remove: ()->
		self = @
		@$el.fadeOut( ()->
			#self.model.destroy()
			self.trigger("model:destroy", @model)
			Marionette.View.prototype.remove.call(self)
		)
}

PanelView = Marionette.View.extend {
	template: template

	triggers: {
		"click button.js-new": "item:new"
	}

	events: {
		"submit #filter-form": "applyFilter"
	}

	ui: {
		criterion: "input.js-filter-criterion"
	},

	applyFilter: (e)->
		e.preventDefault();
		criterion = @ui.criterion.val()
		@trigger("items:filter", criterion);

	onSetFilterCriterion: (criterion)->
		@ui.criterion.val(criterion)

	templateContext: ->
		{
			filterCriterion: @options.filterCriterion or ""
			showAddButton: @options.showAddButton is true
		}
}

RedacteurListView = Marionette.CollectionView.extend {
	tagName: "table"
	className:"table table-hover"
	template: templateList
	childViewContainer: "tbody"
	childView:RedacteurItemView
	childViewEventPrefix: 'item'
	emptyView:RedacteurNoView
	filterCriterion:null

	initialize: ()->
		if @options.filterCriterion
			@filterCriterion = @options.filterCriterion

	triggers:{
		"click a.js-sort-id":"sortid"
		"click a.js-sort-titre":"sorttitre"
	}

	onSortid: (view)->
		if @collection.comparatorAttr is "id"
			@collection.comparatorAttr = "inv_id"
			@collection.comparator = (a,b)->
				if a.get("id")>b.get("id")
					-1
				else
					1
		else
			@collection.comparatorAttr = "id"
			@collection.comparator = "id"
		@collection.sort()

	viewFilter: (child, index, collection) ->
		criterion = @filterCriterion
		model = child.model
		if criterion is "" or criterion is null or model.get("titre").toLowerCase().indexOf(criterion) isnt -1 or model.get("description").toLowerCase().indexOf(criterion) isnt -1
			return true
		else
			return false

	onSetFilterCriterion: (criterion, options)->
		@filterCriterion = criterion.toLowerCase()
		@render()

	flash: (itemModel)->
		itemView = @children.findByModel(itemModel)
		# check whether the new user view is displayed (it could be
		# invisible due to the current filter criterion)
		if itemView then itemView.flash("success")
}

JoueurNoView = Marionette.View.extend {
	template:  templateJoueurNone
	tagName: "a"
	className:"list-group-item list-group-item-action disabled"
}

JoueurItemView = Marionette.View.extend {
	tagName: "a"
	attributes: { href: '#' }
	className: ->
		if @model.get("actif")
			"list-group-item list-group-item-action"
		else
			"list-group-item list-group-item-action disabled"
	template: templateJoueurItem
	triggers: {
		"click": "select"
	}
}

JoueurListView = Marionette.CollectionView.extend {
	tagName: "div"
	className:"list-group"
	childView:JoueurItemView
	childViewEventPrefix: 'item'
	emptyView:JoueurNoView
	filterCriterion:null

	initialize: ()->
		if @options.filterCriterion
			@filterCriterion = @options.filterCriterion

	viewFilter: (child, index, collection) ->
		criterion = @filterCriterion
		model = child.model
		if criterion is "" or criterion is null or model.get("titre").toLowerCase().indexOf(criterion) isnt -1 or model.get("description").toLowerCase().indexOf(criterion) isnt -1
			return true
		else
			return false

	onSetFilterCriterion: (criterion, options)->
		@filterCriterion = criterion.toLowerCase()
		@render()

}

export { RedacteurListView, JoueurListView, PanelView }
