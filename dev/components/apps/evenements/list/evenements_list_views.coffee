import { View, CollectionView } from 'backbone.marionette'
import { SortList, FilterList, DestroyWarn, FlashItem, ToggleItemValue, SubmitClicked, EditItem } from 'apps/common/behaviors.coffee'
import list_evenements_redacteur_tpl from 'templates/evenements/list/list-evenements-redacteur.tpl'
import list_evenements_redacteur_item_tpl from 'templates/evenements/list/list-evenements-redacteur-item.tpl'
import list_evenements_redacteur_none_tpl from 'templates/evenements/list/list-evenements-redacteur-none.tpl'
import edit_evenement_tpl from 'templates/evenements/list/edit-evenement-description.tpl'
import list_evenements_joueur_item_tpl from 'templates/evenements/list/list-evenements-joueur-item.tpl'
import list_evenements_joueur_none_tpl from 'templates/evenements/list/list-evenements-joueur-none.tpl'

#-------------------------
# vues pour un rédacteur -
#-------------------------

NoEvenementView_Redacteur = View.extend {
	template: list_evenements_redacteur_none_tpl
	tagName: "tr"
	className: "table-danger"
}

EvenementItemView_Redacteur = View.extend {
	tagName: "tr"
	template: list_evenements_redacteur_item_tpl
	behaviors: [DestroyWarn, FlashItem, ToggleItemValue]
	triggers: {
		"click a.js-edit": "edit"
		"click button.js-actif": "activation:toggle"
		"click button.js-visible": "visible:toggle"
		"click": "show"
	}

}
EvenementsCollectionView_Redacteur = CollectionView.extend {
	tagName: "table"
	className:"table table-hover"
	template: list_evenements_redacteur_tpl
	childViewContainer: "tbody"
	childView:EvenementItemView_Redacteur
	childViewEventPrefix: 'item'
	emptyView:NoEvenementView_Redacteur
	behaviors: [ SortList, FilterList ]
	filterKeys: ["titre", "description"]
}

EditEvenementView = View.extend {
  behaviors: [SubmitClicked, EditItem]
  template: edit_evenement_tpl
  generateTitle: false
  title: ""
  initialize: ->
    @title = @getOption "title"
  onRender: ->
    if @getOption "generateTitle"
      $title = $("<h1>", { text: @title })
      @$el.prepend($title)
}

#-------------------------
# vues pour un Joueur -
#-------------------------


NoEvenementView_Joueur = View.extend {
	template:  list_evenements_joueur_none_tpl
	tagName: "a"
	className:"list-group-item list-group-item-action disabled"
}

EvenementItemView_Joueur = View.extend {
	tagName: "a"
	attributes: { href: '#' }
	className: ->
		if @model.get("actif")
			"list-group-item list-group-item-action"
		else
			"list-group-item list-group-item-action disabled"
	template: list_evenements_joueur_item_tpl
	triggers: {
		"click": "select"
	}
}

EvenementsCollectionView_Joueur = CollectionView.extend {
	tagName: "div"
	className:"list-group"
	childView:EvenementItemView_Joueur
	childViewEventPrefix: 'item'
	emptyView:NoEvenementView_Joueur
	behaviors: [FilterList]
	filterKeys: ["titre", "description"]
}

export { EvenementsCollectionView_Redacteur, EvenementsCollectionView_Joueur, EditEvenementView }
