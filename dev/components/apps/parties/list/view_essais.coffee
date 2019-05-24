import { View, CollectionView } from 'backbone.marionette'
import templateNone from 'templates/parties/list/essais_none.tpl'
import templateItem from 'templates/parties/list/essai_item.tpl'
import templateList from 'templates/parties/list/essais_list.tpl'

app = require('app').app

NoView = View.extend {
	template:  templateNone
	tagName: "tr"
	className: "alert"
}

ItemView = View.extend {
	tagName: "tr"
	template: templateItem
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

EssaisListView = CollectionView.extend {
	tagName: "table"
	className:"table table-hover"
	template: templateList
	childViewContainer: "tbody"
	childView: ItemView
	childViewEventPrefix: 'item'
	emptyView: NoView
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


export { EssaisListView }
