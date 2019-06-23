import { MnObject } from 'backbone.marionette'
import { MissingView, AlertView, ListLayout } from 'apps/common/commons_view.coffee'
import { IEListPanel, IECollectionView, EditIEDescriptionView } from 'apps/evenements/edit/ie_list_view.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities"
  show: (id) ->
    app.trigger "header:loading", true

    require "entities/dataManager.coffee"
    channel = @getChannel()

    fetchingData = channel.request("custom:entities", ["evenements", "itemsEvenement"])
    $.when(fetchingData).done( (evenements, itemsEvenement)->
      evenement = evenements.get(id)
      if evenement isnt  undefined
        layout = new ListLayout()
        entete = new IEListPanel { model: evenement }
        liste = new IECollectionView { collection: itemsEvenement, idEvenement:evenement.get("id"), addButton: true }

        entete.on "navigate:parent", ->
          app.trigger "evenements:list"

        liste.on "item:new", ()->
          Item = require("entities/itemsEvenement.coffee").Item
          newItem =
          view = new EditIEDescriptionView {
            model: new Item()
            collection: itemsEvenement
            listView: liste
            title: "Nouvel item"
          }
          app.regions.getRegion('dialog').show(view)

        liste.on "item:edit", (childView) ->
          model =
          view = new EditIEDescriptionView {
            model: childView.model
            itemView: childView
            title: "Modification de ##{model.get('id')}"
          }

          app.regions.getRegion('dialog').show(view)

        liste.on "item:show", (childView) ->
          model = childView.model
          idItem = model.get("id")
          idEvenement = model.get("idEvenement")
          app.trigger("evenement:cle:show", idEvenement, idItem)

        layout.on "render", ()->
          layout.getRegion('enteteRegion').show(entete)
          layout.getRegion('itemsRegion').show(liste)
        app.regions.getRegion('main').show(layout)
      else
        view = new MissingView()
        app.regions.getRegion('main').show(view)
    ).fail( (response) ->
      if response.status is 401
        alert("Vous devez vous (re)connecter !")
        app.trigger("home:logout")
      else
        alertView = new AlertView()
        app.regions.getRegion('main').show(alertView)
    ).always( () ->
      app.trigger("header:loading", false)
    )
}

export controller = new Controller()
