import Marionette from 'backbone.marionette'
import templateList from 'templates/parties/list/redacteur_list.tpl'
import templateItem from 'templates/parties/list/redacteur_item.tpl'
import templateNone from 'templates/parties/list/redacteur_none.tpl'
import templateJoueurItem from 'templates/parties/list/joueur_item.tpl'
import templateJoueurNone from 'templates/parties/list/joueur_none.tpl'

app = require('app').app

noView = Marionette.View.extend {
	template:  templateNone
	tagName: "tr"
	className: "alert"
}

ItemView = Marionette.View.extend {
	tagName: "tr"
	template: templateItem
	triggers: {
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

RedacteurListView = Marionette.CollectionView.extend {
	tagName: "table"
	className:"table table-hover"
	template: templateList
	childViewContainer: "tbody"
	childView:ItemView
	childViewEventPrefix: 'item'
	emptyView:noView
	filterCriterion:null

	initialize: ()->
		if @options.filterCriterion
			@filterCriterion = @options.filterCriterion

	triggers:{
		"click a.js-sort-id":"sortid"
		"click a.js-sort-nom":"sortnom"
		"click a.js-sort-dateDebut":"sortdate"
		"click a.js-sort-duree":"sortduree"
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
		if criterion is "" or criterion is null or model.get("nom").toLowerCase().indexOf(criterion) isnt -1 or model.get("titreEvenement").toLowerCase().indexOf(criterion) isnt -1
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
	className:"list-group-item list-group-item-action"
	template: templateJoueurItem
	triggers: {
		"click": "select"
	}
}

JoueurListView = Marionette.CollectionView.extend {
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
