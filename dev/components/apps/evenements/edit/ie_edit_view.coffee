import { View } from 'backbone.marionette'
import templateLayout from "templates/evenements/edit/itemLayout.tpl"
import templatePanel from "templates/evenements/edit/itemPanel.tpl"

PanelView = View.extend {
	template: templatePanel

	triggers:{
		"click a.js-parent" : "navigate:parent"
		"click a.js-add": "subItem:new"
		"click button.js-images": "files:show"
	}

	templateContext: ->
		{
			titreEvenement: @options.evenement.get("titre")
		}
}

ItemLayoutView = View.extend {
	template: templateLayout
	regions: {
		itemsRegion: "#items-region"
		panelRegion: "#panel-region"
	}
}


export { PanelView, ItemLayoutView }

