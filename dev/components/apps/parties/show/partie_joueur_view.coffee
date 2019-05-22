import { View, CollectionView } from 'backbone.marionette'
import templateAccueil from "templates/parties/show/accueil.tpl"
import templatePanel from "templates/parties/show/panel.tpl"
import templateLayout from "templates/parties/show/layout.tpl"
import templateCleItem from "templates/parties/show/cleItem.tpl"

import templateCles from "templates/parties/show/cles.tpl"


PanelView = View.extend {
  template: templatePanel

  events: {
    "submit #essai-form": "essayerCle"
  }

  triggers: {
    "click button.js-gps": "essai:gps"
  }

  ui: {
    essai: "input.js-essai"
  }

  essayerCle: (e)->
    e.preventDefault()
    essai = @ui.essai.val()
    @trigger "essai", essai

  onSetCle: (cle)->
    @ui.essai.val(cle)

  templateContext: ->
    {
      cle: @options.cle ? ""
    }
}





# Clés
CleView = View.extend {
  template: templateCleItem
  tagName: "a"
  attributes: {
    href:"#"
  }
  className: ->
    if @model.get("idItem") is -1 then "badge badge-danger"
    else if @model.get("idItem") is @options.idSelected then "badge badge-warning"
    else "badge badge-primary"
  triggers: {
    "click":"select"
  }
  templateContext: ->
    {
      gps:/^gps=[0-9]+\.[0-9]+,[0-9]+\.[0-9]+(,[0-9]+)?$/.test(@model.get("essai"))
    }
}

CleCollectionView = CollectionView.extend {
  template: templateCles
  childView: CleView
  childViewEventPrefix: 'cle'
  childViewContainer: "#content"
  triggers:{
    "click a.js-home-cle":"home"
  }
  childViewOptions: ->
    {
      idSelected: @options.idSelected
    }
}

AccueilView = View.extend {
  template: templateAccueil
  events:{
    "click a.js-startCle": "clickStartCle"
  }

  clickStartCle: (e)->
    e.preventDefault()
    $el = $(e.currentTarget)
    @trigger("startCle:select",$el.text())

  templateContext: ->
    essaiCle = @options.cle ? ""
    gps = (essaiCle isnt "" and /^gps=[0-9]+\.[0-9]+,[0-9]+\.[0-9]+(,[0-9]+)?$/.test(essaiCle))
    accuracy = -1
    if gps
      arr = essaiCle.split(",")
      if arr.length is 3 then accuracy = Number(arr[2])
    {
      evenement: _.clone(@options.evenement.attributes)
      startCles: @options.startCles
      cle: essaiCle
      gps
      accuracy
    }
}

Layout = View.extend {
  template: templateLayout
  regions: {
    panelRegion: "#panel-region"
    motsRegion: "#mots-region"
    itemRegion: "#item-region"
  }
}

export { AccueilView, PanelView, Layout, CleCollectionView }

