import { View, CollectionView, Behavior } from 'backbone.marionette'
import Syphon from 'backbone.syphon'
import templateLayout from "templates/evenements/edit/itemLayout.tpl"
import templatePanel from "templates/evenements/edit/itemPanel.tpl"

import templateNoSub from "templates/evenements/common/noSubItem.tpl"
import templateImageSub from "templates/evenements/common/image-subItem.tpl"
import templateBrutSub from "templates/evenements/common/brut-subItem.tpl"
import templateSvgSub from "templates/evenements/common/svg-subItem.tpl"

menuButtons = Behavior.extend {
	ui: {
		upButton: 'a.js-up'
		downButton: 'a.js-down'
		editButton: 'a.js-edit'
		deleteButton: 'a.js-delete'
		submitButton: 'button.js-submit'
		showButton: 'a.js-show'
	}

	triggers: {
		'click @ui.upButton': 'up'
		'click @ui.downButton': 'down'
		'click @ui.editButton': 'edit'
		'click @ui.deleteButton': 'delete'
	}

	events: {
		'click @ui.submitButton': 'submitClicked'
		'click @ui.showButton': 'showClicked'
	}

	submitClicked: (e)->
		e.preventDefault()
		data = Syphon.serialize(@view)
		#file = @$el.find("[type='file']")?.prop('files')[0]
		#if file then data.file = file
		#console.log data
		@view.trigger("form:submit", @view, data)

	showClicked: (e)->
		e.preventDefault()
		if @view.editMode
			data = Syphon.serialize(@view)
			@view.trigger("form:submit", @view, data)

}

DefaultItemView = View.extend {
	className: "card"
	template: templateBrutSub
	behaviors: [ menuButtons ]
	editMode: false

	flash: ->
		$view = @$el
		$view.hide().toggleClass("border-success").fadeIn(800, ()->
			setTimeout( ()->
				$view.toggleClass("border-success")
			, 100)
		)

	remove: ()->
		@model.destroy()
		View.prototype.remove.call(@)

	templateContext: ->
		{
			editMode: @editMode
			redacteurMode: true
		}
	onFormDataInvalid: (error)->
		# Il faut effacer le invalid de chaque clé
		$el = $(@el)
		$("[id|='subitem-']").each (index)->
			$(@).removeClass("is-invalid")
		_.mapObject error, (val, key)->
			$el.find("#subitem-#{key}").each (index)->
				$(@).addClass("is-invalid")
}

ImageSubitemView = DefaultItemView.extend {
	template: templateImageSub
	triggers: {
		"click button.js-image": "image:select"
	}
}


EmptyView = View.extend {
	className: "card text-white bg-secondary"
	template: templateNoSub
}

SubItemCollectionView = CollectionView.extend {
	childView:  (model)->
		type = model.get("type")
		switch type
			when "image" then ImageSubitemView
			else DefaultItemView
	emptyView: EmptyView

	childViewEventPrefix: 'subItem'
}

PanelView = View.extend {
	template: templatePanel

	triggers:{
		"click a.js-add": "subItem:new"
		"click button.js-type": "type:toggle"
		"click button.js-images": "files:show"
	}
}

ItemLayoutView = View.extend {
	template: templateLayout
	regions: {
		itemsRegion: "#items-region"
		panelRegion: "#panel-region"
	}
}


export { PanelView, SubItemCollectionView, ItemLayoutView }

