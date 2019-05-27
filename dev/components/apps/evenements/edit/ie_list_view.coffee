import { View, CollectionView } from 'backbone.marionette'
import { SortList, FilterList } from 'apps/common/list_behavior.coffee'
import templateList from 'templates/evenements/edit/list.tpl'
import templateItem from 'templates/evenements/edit/item.tpl'
import templateNone from 'templates/evenements/edit/none.tpl'
import templateLayout from 'templates/evenements/edit/layout.tpl'
import templateEntete from "templates/evenements/edit/entete.tpl"

app = require('app').app

noView = View.extend {
	template:  templateNone
	tagName: "table"
	className:"table table-hover"
	templateContext: ->
		{
			addButton: @options.addButton is true
		}
}

ItemView = View.extend {
	tagName: "tr"
	template: templateItem
	triggers: {
		"click a.js-edit": "edit"
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

Layout = View.extend {
	template: templateLayout
	regions: {
		enteteRegion: "#entete-region"
		panelRegion: "#panel-region"
		itemsRegion: "#items-region"
	}
}

EnteteView = View.extend {
	template: templateEntete
	triggers: {
		"click a.js-parent": "navigate:parent"
	}
	templateContext: ->
		{
			baseUrl: window.location.href.split("#")[0]
		}
}

ListeView = CollectionView.extend {
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
	templateContext: ->
		{
			addButton: @options.addButton is true
		}

	behaviors: [SortList]

	triggers:{
		"click button.js-new": "item:new"
	}

	viewFilter: (child, index, collection) ->
		idE = @options.idEvenement
		model = child.model
		return child.model.get("idEvenement") is idE

}

export { ListeView, Layout, EnteteView }
