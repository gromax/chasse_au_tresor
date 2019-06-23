import { View, CollectionView } from 'backbone.marionette'
import templateList from 'templates/redacteurs/list/list.tpl'
import templateItem from 'templates/redacteurs/list/item.tpl'
import templateNone from 'templates/redacteurs/list/none.tpl'
import { SortList, FilterList, DestroyWarn, FlashItem } from 'apps/common/behaviors.coffee'
import { app } from 'app'

NoRedacteurView = View.extend {
  template:  templateNone
  tagName: "tr"
  className: "alert"
}

RedacteurItemView = View.extend {
  tagName: "tr"
  template: templateItem
  behaviors: [DestroyWarn, FlashItem]
  triggers: {
    "click td a.js-edit": "edit"
    "click td a.js-editPwd": "editPwd"
  }
}

RedacteursCollectionView = CollectionView.extend {
  tagName: "table"
  className:"table table-hover"
  template: templateList
  childViewContainer: "tbody"
  childView:RedacteurItemView
  childViewEventPrefix: 'item'
  emptyView:NoRedacteurView
  behaviors: [SortList, FilterList]
  filterKeys: ["nom", "username"]
}

export { RedacteursCollectionView }
