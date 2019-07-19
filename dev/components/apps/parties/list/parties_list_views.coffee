import { View, CollectionView } from 'backbone.marionette'
import { SortList, FilterList, DestroyWarn, FlashItem } from 'apps/common/behaviors.coffee'

import redacteur_parties_list_tpl from 'templates/parties/list/redacteur_parties_list.tpl'
import redacteur_partie_item_tpl from 'templates/parties/list/redacteur_partie_item.tpl'
import redacteur_parties_none_tpl from 'templates/parties/list/redacteur_parties_none.tpl'
import joueur_partie_item_tpl from 'templates/parties/list/joueur_partie_item.tpl'
import joueur_parties_none_tpl from 'templates/parties/list/joueur_parties_none.tpl'

#-------------------------
# vues pour un rédacteur -
#-------------------------

NoPartie_RedacteurView = View.extend {
  template:  redacteur_parties_none_tpl
  tagName: "tr"
  className: "table-warning"
}

PartieItem_RedacteurView = View.extend {
  tagName: "tr"
  template: redacteur_partie_item_tpl
  behaviors: [DestroyWarn, FlashItem]
  triggers: {
    "click": "show"
  }
  events: {
    "click a.js-event-filter": "eventFilter"
  }

  eventFilter: (e)->
    e.preventDefault()
    e.stopPropagation()
    content = $(e.currentTarget).html()
    @trigger "event:filter", content.split("&nbsp;")[1]

}

PartiesList_RedacteurView = CollectionView.extend {
  tagName: "table"
  className:"table table-hover"
  template: redacteur_parties_list_tpl
  childViewContainer: "tbody"
  childView:PartieItem_RedacteurView
  childViewEventPrefix: 'item'
  emptyView: NoPartie_RedacteurView
  behaviors: [SortList, FilterList]
  filterKeys: ["nom","titreEvenement"]
}

#----------------------
# vues pour un joueur -
#----------------------

NoPartie_JoueurView = View.extend {
  template:  joueur_parties_none_tpl
  tagName: "a"
  className: "list-group-item list-group-item-action disabled"
}

PartieItem_JoueurView = View.extend {
  tagName: "a"
  attributes: { href: '#' }
  template: joueur_partie_item_tpl
  className: ->
    if @model.get("actif")
      "list-group-item list-group-item-action"
    else
      "list-group-item list-group-item-danger list-group-item-action"
  triggers: {
    "click": "select"
  }
}

PartiesList_JoueurView = CollectionView.extend {
  tagName: "div"
  className:"list-group"
  childView:PartieItem_JoueurView
  childViewEventPrefix: "item"
  emptyView:NoPartie_JoueurView
  behaviors: [FilterList]
  filterKeys: ["titre", "description"]
}

export { PartiesList_RedacteurView, PartiesList_JoueurView }
