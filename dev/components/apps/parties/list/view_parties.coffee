import { View, CollectionView } from 'backbone.marionette'
import templateRedacteurList from 'templates/parties/list/redacteur_parties_list.tpl'
import templateRedacteurItem from 'templates/parties/list/redacteur_partie_item.tpl'
import templateRedacteurNone from 'templates/parties/list/redacteur_parties_none.tpl'
import templateJoueurItem from 'templates/parties/list/joueur_partie_item.tpl'
import templateJoueurNone from 'templates/parties/list/joueur_parties_none.tpl'

app = require('app').app

RedacteurNoView = View.extend {
	template:  templateRedacteurNone
	tagName: "tr"
	className: "alert"
}

RedacteurItemView = View.extend {
	tagName: "tr"
	template: templateRedacteurItem
	triggers: {
		"click": "show"
		"click button.js-delete": "delete"
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
			View.prototype.remove.call(self)
		)
}

RedacteurListView = CollectionView.extend {
	tagName: "table"
	className:"table table-hover"
	template: templateRedacteurList
	childViewContainer: "tbody"
	childView:RedacteurItemView
	childViewEventPrefix: 'item'
	emptyView:RedacteurNoView
	filterCriterion:null

	initialize: ()->
		if @options.filterCriterion
			@filterCriterion = @options.filterCriterion

	events: {
		"click a.js-sort":"sortFct"
	}

	sortFct: (e)->
		e.preventDefault()
		tag = $(e.currentTarget).attr("sort")
		if @collection.comparatorAttr is tag
			@collection.comparatorAttr = "inv_"+tag
			@collection.comparator = (a,b)->
				if a.get(tag)>b.get(tag)
					-1
				else
					1
		else
			@collection.comparatorAttr = tag
			@collection.comparator = tag
		@collection.sort()

	viewFilter: (child, index, collection) ->
		criterion = @filterCriterion
		model = child.model
		if criterion is "" or criterion is null
			return true
		strModel = (model.get("nom") + ";" + model.get("titreEvenement")).normalize('NFD').replace(/[\u0300-\u036f]/g, "").toLowerCase()
		if strModel.indexOf(criterion) isnt -1
			return true
		else
			return false

	onSetFilterCriterion: (criterion, options)->
		@filterCriterion = criterion.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toLowerCase()
		@render()

	flash: (itemModel)->
		itemView = @children.findByModel(itemModel)
		# check whether the new user view is displayed (it could be
		# invisible due to the current filter criterion)
		if itemView then itemView.flash("success")

}



JoueurNoView = View.extend {
	template:  templateJoueurNone
	tagName: "a"
	className:"list-group-item list-group-item-action disabled"
}

JoueurItemView = View.extend {
	tagName: "a"
	attributes: { href: '#' }
	className: ->
		if @model.get("actif")
			"list-group-item list-group-item-action"
		else
			"list-group-item list-group-item-danger list-group-item-action"
	template: templateJoueurItem
	triggers: {
		"click": "select"
	}
}

JoueurListView = CollectionView.extend {
	tagName: "div"
	className:"list-group"
	childView:JoueurItemView
	childViewEventPrefix: "item"
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

export { RedacteurListView, JoueurListView }
