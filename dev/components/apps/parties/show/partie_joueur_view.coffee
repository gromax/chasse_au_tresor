import { View, CollectionView } from 'backbone.marionette'
import Syphon from 'backbone.syphon'
import templateAccueil from "templates/parties/show/accueil.tpl"
import templatePanel from "templates/parties/show/panel.tpl"
import templateLayout from "templates/parties/show/layout.tpl"

import templateNoSub from "templates/evenements/common/noSubItem.tpl"
import templateImageSub from "templates/evenements/common/image-subItem.tpl"
import templateBrutSub from "templates/evenements/common/brut-subItem.tpl"
import templateSvgSub from "templates/evenements/common/svg-subItem.tpl"

import templateCles from "templates/parties/show/cles.tpl"


PanelView = View.extend {
	template: templatePanel

	events: {
		"submit #essai-form": "essayerCle"
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

SubItemView = View.extend {
  className: "card"
  attributes: ->
    if @model.get("type") is "image" and @model.get("width") isnt "100%"
      { style:"width:#{@model.get("width")};"}
    else
      {}
  getTemplate: ->
    type = @model.get("type")
    switch type
      when "image" then templateImageSub
      when "svg" then templateSvgSub
      else templateBrutSub

  templateContext: ->
    {
      editMode: false
      redacteurMode: false
    }
}

# Clés
CleView = View.extend {
  tagName: "a"
  attributes: {
    href:"#"
  }
  className: ->
    if @model.get("id") is @options.idSelected then "badge badge-warning"
    else "badge badge-primary"
  template: _.template("<%-essai%>")
  triggers: {
    "click":"select"
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

# Les items

EmptyView = View.extend {
  className: "card text-white bg-secondary"
  template: templateNoSub
}

SubItemCollectionView = CollectionView.extend {
  childView:  SubItemView
  emptyView: EmptyView
  childViewEventPrefix: 'subItem'
}



AccueilView = View.extend {
  template: templateAccueil
  events:{
    "click a.js-startCle": "clickStartCle"
  }

  clickStartCle: (e)->
    e.preventDefault()
    $el = $(e.currentTarget)
    @trigger("essai",$el.text())

  templateContext: ->
    {
      evenement: _.clone(@options.evenement.attributes)
      startCles: @options.startCles
      cle: @options.cle ? ""
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

export { AccueilView, PanelView, SubItemCollectionView, Layout, CleCollectionView }

