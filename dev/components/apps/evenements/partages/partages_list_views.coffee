import { View, CollectionView } from 'backbone.marionette'
import templateList from 'templates/evenements/partages/partage-list.tpl'
import templateItem from 'templates/evenements/partages/partage-item.tpl'
import templateNone from 'templates/evenements/partages/partage-no-item.tpl'
import list_layout_tpl from 'templates/evenements/partages/partages-list-layout.tpl'
import add_partage_item_tpl from 'templates/evenements/partages/partage-add-item.tpl'
import add_partage_no_item_tpl from 'templates/evenements/partages/partage-add-no-item.tpl'
import { SortList, FilterList, DestroyWarn, FlashItem } from 'apps/common/behaviors.coffee'
import { app } from 'app'

NoPartageView = View.extend {
  template:  templateNone
  tagName: "tr"
  className: "table-warning"
}

PartagesListLayout = View.extend {
  template: list_layout_tpl
  regions: {
    enteteRegion: "#entete-region"
    panelRegion: "#panel-region"
    itemsRegion: "#items-region"
  }
}

PartageItemView = View.extend {
  tagName: "tr"
  template: templateItem
  behaviors: [DestroyWarn, FlashItem]
  #triggers: {
  #}
}

PartageAddItem = View.extend {
  tagName: "a"
  attributes: { href:"#" }
  behaviors: [DestroyWarn, FlashItem]
  className: "list-group-item list-group-item-action"
  template: add_partage_item_tpl
  triggers: {
    'click' : 'add'
  }
}

PartageAddNoItem = View.extend {
  tagName: "a"
  attributes: { href:"#" }
  className: "list-group-item list-group-item-action list-group-item-warning"
  template: add_partage_no_item_tpl
}

PartageAddListItems = CollectionView.extend {
  initialize: ->
    @title = "Ajouter un partage"
  className: "list-group"
  childView: PartageAddItem
  emptyView: PartageAddNoItem
  childViewEventPrefix: 'item'
}

PartagesCollectionView = CollectionView.extend {
  className: "table-responsive"
  template: templateList
  childView: PartageItemView
  emptyView: NoPartageView
  childViewContainer: "tbody"
  childViewEventPrefix: 'item'
  behaviors: [SortList, FilterList]
  filterKeys: ["nom"]
}

export { PartagesCollectionView, PartagesListLayout, PartageAddListItems }
