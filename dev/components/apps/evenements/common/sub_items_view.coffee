import { View, CollectionView, Behavior } from 'backbone.marionette'
import Syphon from 'backbone.syphon'
import templateNoSub from "templates/evenements/common/noSubItem.tpl"
import templateImageSub from "templates/evenements/common/image-subItem.tpl"
import templateBrutSub from "templates/evenements/common/brut-subItem.tpl"
import templateSvgSub from "templates/evenements/common/svg-subItem.tpl"


menuButtons = Behavior.extend {
  ui: {
    upButton: 'a.js-up'
    downButton: 'a.js-down'
    editButton: 'a.js-edit'
    deleteButton: 'a.js-delete'
    submitButton: 'button.js-submit'
    showButton: 'a.js-show'
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
}

SubEmptyView = View.extend {
  className: "card text-white bg-secondary"
  template: templateNoSub
}

SubItemView = View.extend {
  className: "card"
  template: templateBrutSub

  templateContext: ->
    {
      editMode: false
      redacteurMode: false
    }
}

redacteurExtension = {
  behaviors: [ menuButtons ]
  editMode: false
  redacteurMode: true

  flash: ->
    $view = @$el
    $view.hide().toggleClass("border-success").fadeIn(800, ()->
      setTimeout( ()->
        $view.toggleClass("border-success")
      , 100)
    )

  remove: ()->
    @model.destroy()
    View.prototype.remove.call(@)

  templateContext: ->
    {
      editMode: @editMode
      redacteurMode: true
    }

  onFormDataInvalid: (error)->
    # Il faut effacer le invalid de chaque clé
    $el = $(@el)
    $("[id|='subitem-']").each (index)->
      $(@).removeClass("is-invalid")
    _.mapObject error, (val, key)->
      $el.find("#subitem-#{key}").each (index)->
        $(@).addClass("is-invalid")
}

# Item image
SubItemImageView = SubItemView.extend {
  template: templateImageSub
  attributes: ->
    if @model.get("width") isnt "100%" and @redacteurMode isnt true
      { style:"width:#{@model.get("width")};"}
    else
      {}
}

# En version redac
RedacSubItemImageView = SubItemImageView.extend({
  triggers: {
    "click button.js-image": "image:select"
  }
}).extend(redacteurExtension)

# Item SVG
SubItemSVGView = SubItemView.extend {
  template: templateSvgSub
}

# Item de type brut

SubItemBrutView = SubItemView.extend {
  template: templateBrutSub
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

# on ajoute les événements utiles


RedacSubItemSVGView = SubItemSVGView.extend redacteurExtension
RedacSubItemBrutView = SubItemBrutView.extend redacteurExtension
RedacSubItemView = SubItemView.extend redacteurExtension

SubItemCollectionView = CollectionView.extend {
  childView:  (model)->
    type = model.get("type")
    if @options.redacteurMode is true
      switch type
        when "image" then RedacSubItemImageView
        when "svg" then RedacSubItemSVGView
        when "brut" then RedacSubItemBrutView
        else RedacSubItemView
    else
      switch type
        when "image" then SubItemImageView
        when "svg" then SubItemSVGView
        when "brut" then SubItemBrutView
        else SubItemView
  emptyView: SubEmptyView
  childViewEventPrefix: 'subItem'
}

export { SubItemCollectionView }
