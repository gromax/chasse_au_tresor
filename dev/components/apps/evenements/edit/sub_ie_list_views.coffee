import { View, CollectionView, Behavior } from 'backbone.marionette'
import Syphon from 'backbone.syphon'
import { SubmitClicked, FlashItem } from 'apps/common/behaviors.coffee'
import sub_ie_list_panel_tpl from "templates/evenements/edit/subItems/sub-ie-list-panel.tpl"
import sub_ie_list_none_tpl from "templates/evenements/edit/subItems/sub-ie-list-none.tpl"
import sub_ie_list_item_brut_tpl from "templates/evenements/edit/subItems/sub-ie-list-item-brut.tpl"
import sub_ie_list_item_image_tpl from "templates/evenements/edit/subItems/sub-ie-list-item-image.tpl"
import sub_ie_list_item_svg_tpl from "templates/evenements/edit/subItems/sub-ie-list-item-svg.tpl"


SubIEListPanel = View.extend {
  template: sub_ie_list_panel_tpl
  triggers:{
    "click a.js-parent" : "navigate:parent"
    "click a.js-add": "subItem:new"
    "click button.js-images": "files:show"
  }

  templateContext: ->
    {
      titreEvenement: @getOption("evenement")?.get("titre")
    }
}

MenuButtons = Behavior.extend {
  ui: {
    upButton: 'a.js-up'
    downButton: 'a.js-down'
    editButton: 'a.js-edit'
    showButton: 'a.js-show'
    deleteButton: 'a.js-delete'
    submitButton: 'button.js-submit'
  }

  triggers: {
    'click @ui.upButton': 'up'
    'click @ui.downButton': 'down'
    'click @ui.editButton': 'edit'
    'click @ui.deleteButton': 'delete'
  }

  events: {
    'click @ui.submitButton': 'submitClicked'
    'click @ui.showButton': 'showClicked'
  }

  submitClicked: (e)->
    e.preventDefault()
    data = Syphon.serialize(@view)
    #file = @$el.find("[type='file']")?.prop('files')[0]
    #if file then data.file = file
    #console.log data
    @view.trigger("form:submit", @view, data)

  showClicked: (e)->
    e.preventDefault()
    if @view.editMode
      data = Syphon.serialize(@view)
      @view.trigger("form:submit", @view, data)

  onUp: ->
    current = @view.model
    index = current.get "index"
    parentView = @view.getOption "parentView"
    collection = parentView?.collection
    if index>0 and collection?
      prev = collection.findWhere({index:index-1})
      if prev
        prev.set('index', index)
        current.set('index', index-1)
        collection.sort()
        item = parentView.getOption "itemEvenement"
        @saveAfterEvent()

  onDown: ->
    current = @view.model
    index = current.get "index"
    parentView = @view.getOption "parentView"
    collection = parentView?.collection
    if collection?
      suiv = collection.findWhere {index:index+1}
      if suiv
        suiv.set 'index', index
        current.set 'index', index+1
        collection.sort()
        @saveAfterEvent()

  onDelete: ->
    if confirm("Effacer l'élément ?")
      model = childView.model
      model.destroy()
      @saveAfterEvent(collection, parentView)

  onSubmit: ->
    model = childView.model
    validationResult = model.set(data, {validate:true})
    if validationResult
      #switch type
      # when "brut"
      #   model.set(data)
      # when "image"
      @saveAfterEvent()
    else
      @view.trigger "form:data:invalid",model.validationError

  saveAfterEvent: ->
    parentView = @view.getOption "parentView"
    collection = parentView?.collection
    if (item=parentView.getOption("itemEvenement"))? and collection?
      item.set "subItemsData", JSON.stringify(collection.toJSON())
      updatingItem = item.save()
      app = require('app').app
      app.trigger "header:loading", true
      $.when(updatingItem).done( ->
      ).fail( (response)->
        switch response.status
          when 401
            alert("Vous devez vous (re)connecter !")
            app.trigger("home:logout")
          else
            alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur")
      ).always( ->
        app.trigger "header:loading", false
      )
}

RedacteurExtensions = {
  behaviors: [ MenuButtons, SubmitClicked, FlashItem ]
  editMode: false
  redacteurMode: true

  templateContext: ->
    {
      editMode: @editMode
      redacteurMode: true
    }
}

NoSubIEView = View.extend {
  className: "card text-white bg-secondary"
  template: templateNoSub
}

# SubItem de base
SubIEItemView = View.extend {
  className: "card"
  templateContext: ->
    {
      editMode: false
      redacteurMode: false
    }
}

# SubItem image
SubIEItemImageView = SubIEItemView.extend {
  template: sub_ie_list_item_image_tpl
  attributes: ->
    if @model.get("width") isnt "100%" and @redacteurMode isnt true
      { style:"width:#{@model.get("width")};"}
    else
      {}
}

# En version redac
SubIEItemImageView_Redacteur = SubIEItemImageView.extend({
  triggers: {
    "click button.js-image": "image:select"
  }
}).extend(RedacteurExtensions)

# Item SVG
SubIEItemSVGView = SubIEItemView.extend {
  template: sub_ie_list_item_svg_tpl
}

# Item de type brut
SubIEItemBrutView = SubIEItemView.extend {
  template: sub_ie_list_item_brut_tpl
  events: {
    "click a.js-cle": "clickCle"
  }
  clickCle:(e)->
    e.preventDefault()
    $link = $(e.currentTarget)
    cible = $link.attr("cible")
    @trigger("click:cle", cible)
  serializeData: ->
    data = _.clone(@model.attributes)
    if @editMode isnt true
      remplaceurCleAvecTag=(correspondance, p1, p2, p3, decalage, chaine) ->
        if typeof p2 is "undefined"
          "<a href='#' class='badge badge-success js-cle' cible='#{p3}'>#{p3}</a>"
        else
          "<a href='#' class='badge badge-success js-cle' cible='#{p2}'>#{p3}</a>"
      data.contenu = data.contenu.replace(/\[link(=(.*))?\](.*)\[\/link\]/gi, remplaceurCleAvecTag)
    data
}

SubIEItemSVGView_Redacteur = SubIEItemSVGView.extend redacteurExtension
SubIEItemBrutView_Redacteur = SubIEItemBrutView.extend redacteurExtension

SubIECollectionView = CollectionView.extend {
  childView:  (model)->
    type = model.get("type")
    if @options.redacteurMode is true
      switch type
        when "image" then SubIEItemImageView_Redacteur
        when "svg" then SubIEItemSVGView_Redacteur
        else SubIEItemBrutView_Redacteur
    else
      switch type
        when "image" then SubIEItemImageView
        when "svg" then SubIEItemSVGView
        else SubIEItemBrutView
  emptyView: NoSubIEView
  childViewEventPrefix: 'subItem'
  childViewOptions: ->
    {
      parentView: @
    }
}

export { SubIECollectionView, SubIEListPanel }
