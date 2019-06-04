import { View, CollectionView } from 'backbone.marionette'
import { SortList } from 'apps/common/list_behavior.coffee'
import templateNone from 'templates/parties/list/essais_none.tpl'
import templateItem from 'templates/parties/list/essai_item.tpl'
import templateList from 'templates/parties/list/essais_list.tpl'
import templatePanel from 'templates/parties/list/entete_essais.tpl'

app = require('app').app

EssaisEntetePanel = View.extend {
	className: "card"
	template: templatePanel
	triggers: {
		"click a.js-parent": "navigate:parent"
	}
	templateContext: ->
		reduceFct = (s,it) -> s+it.get("pts")
		{
			idPartie: @options.partie.get("id")
			titreEvenement: @options.evenement.get("titre")
			descriptionEvenement: @options.evenement.get("description")
			actif: @options.evenement.get("actif")
			score: @options.essais.reduce( reduceFct,0 )
			nomJoueur: @options.nomJoueur
		}
}


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
	}
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

	behaviors: [SortList]

	initialize: ()->
		if @options.filterCriterion
			@filterCriterion = @options.filterCriterion

}


export { EssaisListView, EssaisEntetePanel }
