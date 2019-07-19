import { View, CollectionView } from 'backbone.marionette'
import templateList from 'templates/joueurs/list/list.tpl'
import joueur_item_tpl from 'templates/joueurs/list/item.tpl'
import no_joueur_tpl from 'templates/joueurs/list/none.tpl'
import { SortList, FilterList, DestroyWarn, FlashItem } from 'apps/common/behaviors.coffee'
import { app } from 'app'

NoJoueurView = View.extend {
  template:  no_joueur_tpl
  tagName: "tr"
  className: "table-warning"
}

JoueurItemView = View.extend {
  tagName: "tr"
  template: joueur_item_tpl
  behaviors: [DestroyWarn, FlashItem]
  triggers: {
    "click td a.js-edit": "edit"
    "click td a.js-editPwd": "editPwd"
  }
}

JoueursCollectionView = CollectionView.extend {
  tagName: "table"
  className: "table table-hover"
  template: templateList
  childViewContainer: "tbody"
  childView: JoueurItemView
  childViewEventPrefix: "item"
  emptyView: NoJoueurView
  behaviors: [SortList, FilterList]
  filterKeys: ["nom", "username"]
}

export { JoueursCollectionView }
