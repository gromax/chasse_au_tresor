import Marionette from 'backbone.marionette'
import templateList from 'templates/evenements/edit/list.tpl'
import templateItem from 'templates/evenements/edit/item.tpl'
import templateNone from 'templates/evenements/edit/none.tpl'
import templateLayout from 'templates/evenements/edit/layout.tpl'
import templateEntete from "templates/evenements/edit/entete.tpl"

app = require('app').app

noView = Marionette.View.extend {
	template:  templateNone
	tagName: "table"
	className:"table table-hover"
	templateContext: ->
		{
			addButton: @options.addButton is true
		}
}

ItemView = Marionette.View.extend {
	tagName: "tr"
	template: templateItem
	triggers: {
		"click a.js-edit": "edit"
		"click button.js-type": "type:toggle"
		"click button.js-delete": "delete"
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

Layout = Marionette.View.extend {
	template: templateLayout
	regions: {
		enteteRegion: "#entete-region"
		panelRegion: "#panel-region"
		itemsRegion: "#items-region"
	}
}

EnteteView = Marionette.View.extend {
	template: templateEntete
	triggers: {
		"click a.js-parent": "navigate:parent"
	}
}

ListeView = Marionette.CollectionView.extend {
	tagName: "table"
	className:"table table-hover"
	template: templateList
	childViewContainer: "tbody"
	childView:ItemView
	childViewEventPrefix: 'item'
	emptyView: noView
	emptyViewOptions: ->
		{
			addButton: @options.addButton is true
		}
	filterCriterion:null
	templateContext: ->
		{
			addButton: @options.addButton is true
		}

	triggers:{
		"click a.js-sort-id":"sortid"
		"click a.js-sort-type":"sorttype"
		"click a.js-sort-cle":"sortcle"
		"click button.js-new": "item:new"
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
		idE = @options.idEvenement
		model = child.model
		return child.model.get("idEvenement") is idE

}

export { ListeView, Layout, EnteteView }
