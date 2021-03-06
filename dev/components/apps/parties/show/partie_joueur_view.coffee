import { View, CollectionView } from 'backbone.marionette'
import accueil_tpl from "templates/parties/show/accueil.tpl"
import panel_tpl from "templates/parties/show/panel.tpl"
import layout_tpl from "templates/parties/show/layout.tpl"
import cleItem_tpl from "templates/parties/show/cleItem.tpl"
import cles_list_tpl from "templates/parties/show/cles_list.tpl"

# Panneau de recherche : input + submit + bouton GPS
PartiePanelView = View.extend {
  cle: ""
  actif: true
  template: panel_tpl
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
      cle: @getOption "cle"
      actif: @getOption "actif"
    }
}

# Panneau des clés déjà trouvées
# Ici, vu d'une seule clé
CleItemView = View.extend {
  template: cleItem_tpl
  tagName: "a"
  attributes: {
    href:"#"
    style:"font-size:15px"
  }
  className: ->
    if @model.get("idItem") is -1 then "list-group-item list-group-item-action list-group-item-danger d-flex justify-content-between"
    else if @model.get("idItem") is @options.idSelected then "list-group-item list-group-item-action list-group-item-warning d-flex justify-content-between"
    else "list-group-item list-group-item-action list-group-item-primary d-flex justify-content-between"
  triggers: {
    "click":"select"
  }
  templateContext: ->
    {
      gps:/^gps=[0-9]+\.[0-9]+,[0-9]+\.[0-9]+(,[0-9]+)?$/.test(@model.get("essai"))
    }
}

# Ici vue de l'ensemble des clés
ClesCollectionView = CollectionView.extend {
  template:cles_list_tpl
  childView: CleItemView
  childViewEventPrefix: 'cle'
  childViewContainer: ".js-cles-list"
  showErreursEtFinisVisiblesButton:true
  erreursetfinisVisibles: true
  events: {
    "click a.js-erreursetfinisVisiblesToggle": "erreursetfinisVisiblesToggle"
  }
  triggers: {
    "click a.js-refresh": "click:refresh:button"
  }
  erreursetfinisVisiblesToggle: (e) ->
    e.preventDefault()
    $dom = e.currentTarget
    @options.erreursetfinisVisibles = not (@getOption "erreursetfinisVisibles")
    $label = $("small", $dom)
    $ico = $(".fa", $dom)
    if @options.erreursetfinisVisibles
      $ico.removeClass("fa-eye-slash").addClass("fa-eye")
      $label.html "Erreurs et finis visibles"
    else
      $ico.removeClass("fa-eye").addClass("fa-eye-slash")
      $label.html "Erreurs et finis cachés"
    @trigger "erreursetfinis:visibles:toggle"
  templateContext: ->
    {
      erreursetfinisVisibles: @getOption "erreursetfinisVisibles"
      showErreursEtFinisVisiblesButton: @getOption "showErreursEtFinisVisiblesButton"
    }
  childViewOptions: ->
    {
      idSelected: @options.idSelected
    }
  onShowMessageNews: ->
    $("div.d-none", @$el).removeClass('d-none')
}

# panneau d'accueil quand aucune clé n'est trouvée ou en cas d'erreur
PartieAccueilView = View.extend {
  template: accueil_tpl
  cleSaved: true
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
      cleSaved: @getOption "cleSaved"
    }
}

# disposition de l'ensemble des vues
PartieLayout = View.extend {
  template: layout_tpl
  regions: {
    panelRegion: "#panel-region"
    motsRegion: "#mots-region"
    itemRegion: "#item-region"
  }
}

export { PartieAccueilView, PartiePanelView, PartieLayout, ClesCollectionView }

