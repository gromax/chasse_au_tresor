import Marionette from 'backbone.marionette'
import Syphon from 'backbone.syphon'
import templateLayout from "templates/evenements/edit/itemLayout.tpl"
import templatePanel from "templates/evenements/edit/itemPanel.tpl"
import templateNoSub from "templates/evenements/edit/noSubItem.tpl"
import templateSub from "templates/evenements/edit/subItem.tpl"

DefaultItemView = Marionette.View.extend {
	className: "card"
	template: templateSub
	triggers: {
		"click a.js-up":"up"
		"click a.js-down":"down"
		"click a.js-delete":"delete"
		"click a.js-edit":"edit"
		"click button.js-image": "image"
	}

	events: {
		"click button.js-submit": "submitClicked"
		"click a.js-show":"showClicked"
	}

	showClicked: (e)->
		e.preventDefault()
		if @model.get("editMode")
			data = Syphon.serialize(@)
			@trigger("form:submit", @, data)

	submitClicked: (e)->
		e.preventDefault()
		data = Syphon.serialize(@)
		#file = @$el.find("[type='file']")?.prop('files')[0]
		#if file then data.file = file
		#console.log data
		@trigger("form:submit", @, data)

	flash: ->
		$view = @$el
		$view.hide().toggleClass("border-success").fadeIn(800, ()->
			setTimeout( ()->
				$view.toggleClass("border-success")
			, 100)
		)

	remove: ()->
		@model.destroy()
		Marionette.View.prototype.remove.call(@)
}

EmptyView = Marionette.View.extend {
	className: "card text-white bg-secondary"
	template: templateNoSub
}

SubItemCollectionView = Marionette.CollectionView.extend {
	childView:  (model)->
		type = model.get("type")
		#switch type
		#	else return DefaultItemView
		return DefaultItemView
	emptyView: EmptyView
	childViewEventPrefix: 'subItem'
}

ItemPanelView = Marionette.View.extend {
	template: templatePanel

	triggers:{
		"click a.js-add": "subItem:new"
		"click button.js-type": "type:toggle"
		"click button.js-images": "images:show"
	}
}

ItemLayoutView = Marionette.View.extend {
	template: templateLayout
	regions: {
		itemsRegion: "#items-region"
		panelRegion: "#panel-region"
	}
}


export { ItemPanelView, SubItemCollectionView, ItemLayoutView }

