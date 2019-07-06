import { View, CollectionView } from 'backbone.marionette'
import { SortList, DestroyWarn } from 'apps/common/behaviors.coffee'
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
  behaviors: [DestroyWarn]
  template: list_essais_item_tpl
  className: ->
    pts = @model.get "pts"
    switch
      when pts <0 then "table-danger"
      when pts >0 then "table-success"
      else ""
  triggers: {
    "click": "show"
  }
  templateContext: ->
    prerequis = @model.get("prerequis")
    prerequisOk = true
    if prerequis isnt ""
      ids = @getOption "ids"
      listMINTERMS = prerequis.split("|")
      if listMINTERMS.length>0
        prerequisOk=false
        for it in listMINTERMS
          litterals = it.split("&")
          notMeetingPrerequisFound = false
          for lit in litterals
            if not _.contains(ids,Number(lit))
              notMeetingPrerequisFound = true
              break
          unless notMeetingPrerequisFound
            prerequisOk = true
            break
    {
      prerequisOk
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
  childViewOptions: ->
    {
      ids: @collection.pluck "idItem"
    }
}

export { EssaisCollectionView, ListEssaisPanel }
