import { View, CollectionView } from 'backbone.marionette'
import { SortList } from 'apps/common/behaviors.coffee'
import list_essais_none_tpl from 'templates/parties/list/list_essais_none.tpl'
import list_essais_item_tpl from 'templates/parties/list/list_essai_item.tpl'
import list_essais_tpl from 'templates/parties/list/list_essais.tpl'
import list_essais_panel_tpl from 'templates/parties/list/list_essais_panel.tpl'

ListEssaisPanel = View.extend {
  className: "card"
  template: list_essais_panel_tpl
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
  template: list_essais_none_tpl
  tagName: "tr"
  className: "alert"
}

ItemView = View.extend {
  tagName: "tr"
  template: list_essais_item_tpl
  triggers: {
    "click": "show"
  }
}

EssaisCollectionView = CollectionView.extend {
  tagName: "table"
  className:"table table-hover"
  template: list_essais_tpl
  childViewContainer: "tbody"
  childView: ItemView
  childViewEventPrefix: 'item'
  emptyView: NoView
  behaviors: [SortList]
}

export { EssaisCollectionView, ListEssaisPanel }
