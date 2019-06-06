import { View, CollectionView } from 'backbone.marionette'
import { SortList, FilterList, DestroyWarn } from 'apps/common/behaviors.coffee'
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
	behaviors: [DestroyWarn]
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
}

RedacteurListView = CollectionView.extend {
	tagName: "table"
	className:"table table-hover"
	template: templateRedacteurList
	childViewContainer: "tbody"
	childView:RedacteurItemView
	childViewEventPrefix: 'item'
	emptyView:RedacteurNoView
	behaviors: [SortList, FilterList]
	filterKeys: ["nom","titreEvenement"]
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
	behaviors: [FilterList]
	filterKeys: ["titre", "description"]
}

export { RedacteurListView, JoueurListView }
