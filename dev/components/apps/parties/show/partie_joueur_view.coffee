import { View, CollectionView } from 'backbone.marionette'
import templateAccueil from "templates/parties/show/accueil.tpl"
import templatePanel from "templates/parties/show/panel.tpl"
import templateLayout from "templates/parties/show/layout.tpl"
import templateCleItem from "templates/parties/show/cleItem.tpl"


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
    style:"font-size:15px"
  }
  className: ->
    if @model.get("idItem") is -1 then "list-group-item list-group-item-action list-group-item-danger"
    else if @model.get("idItem") is @options.idSelected then "list-group-item list-group-item-action list-group-item-warning"
    else "list-group-item list-group-item-action list-group-item-primary"
  triggers: {
    "click":"select"
  }
  templateContext: ->
    {
      gps:/^gps=[0-9]+\.[0-9]+,[0-9]+\.[0-9]+(,[0-9]+)?$/.test(@model.get("essai"))
    }
}

CleCollectionView = CollectionView.extend {
  className: "list-group"
  childView: CleView
  childViewEventPrefix: 'cle'
  #childViewContainer: "#content"
  childViewOptions: ->
    {
      idSelected: @options.idSelected
    }
}

AccueilView = View.extend {
  template: templateAccueil

  templateContext: ->
    essaiCle = @options.cle ? ""
    gps = (essaiCle isnt "" and /^gps=[0-9]+\.[0-9]+,[0-9]+\.[0-9]+(,[0-9]+)?$/.test(essaiCle))
    accuracy = -1
    if gps
      arr = essaiCle.split(",")
      if arr.length is 3 then accuracy = Number(arr[2])
    {
      evenement: _.clone(@options.evenement.attributes)
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

