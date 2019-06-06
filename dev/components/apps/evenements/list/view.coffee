import { View, CollectionView } from 'backbone.marionette'
import { SortList, FilterList, DestroyWarn } from 'apps/common/behaviors.coffee'
import RedacteurList_tpl from 'templates/evenements/list/redacteur_list.tpl'
import templateRedacteurItem from 'templates/evenements/list/redacteur_item.tpl'
import templateRedacteurNone from 'templates/evenements/list/redacteur_none.tpl'

import templateJoueurItem from 'templates/evenements/list/joueur_item.tpl'
import templateJoueurNone from 'templates/evenements/list/joueur_none.tpl'



app = require('app').app

RedacteurNoView = View.extend {
	template: templateRedacteurNone
	tagName: "tr"
	className: "alert"
}

RedacteurItemView = View.extend {
	tagName: "tr"
	template: templateRedacteurItem
	behaviors: [DestroyWarn]
	triggers: {
		"click a.js-edit": "edit"
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

}

RedacteurListView = CollectionView.extend {
	tagName: "table"
	className:"table table-hover"
	template: RedacteurList_tpl
	childViewContainer: "tbody"
	childView:RedacteurItemView
	childViewEventPrefix: 'item'
	emptyView:RedacteurNoView
	behaviors: [ SortList, FilterList ]
	filterKeys: ["titre", "description"]
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
			"list-group-item list-group-item-action disabled"
	template: templateJoueurItem
	triggers: {
		"click": "select"
	}
}

JoueurListView = CollectionView.extend {
	tagName: "div"
	className:"list-group"
	childView:JoueurItemView
	childViewEventPrefix: 'item'
	emptyView:JoueurNoView
	behaviors: [FilterList]
	filterKeys: ["titre", "description"]
}

export { RedacteurListView, JoueurListView }
