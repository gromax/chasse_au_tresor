import { MnObject } from 'backbone.marionette'
import { ListLayout } from 'apps/common/common_views.coffee'
import { IEListPanel, IECollectionView, EditIEDescriptionView } from 'apps/evenements/edit/ie_list_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities"
  show: (id) ->
    app.trigger "loading:up"

    require "entities/dataManager.coffee"
    channel = @getChannel()

    fetchingData = channel.request "custom:entities", ["evenements", "itemsEvenement"]
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
            model: new Item({ idEvenement:id})
            collection: itemsEvenement
            listView: liste
            title: "Nouvel item"
          }
          app.regions.getRegion('dialog').show(view)

        liste.on "item:edit", (childView) ->
          model = childView.model
          view = new EditIEDescriptionView {
            model: model
            itemView: childView
            title: "Modification de ##{model.get('id')}"
          }

          app.regions.getRegion('dialog').show(view)

        liste.on "item:show", (childView) ->
          model = childView.model
          idItem = model.get("id")
          idEvenement = model.get("idEvenement")
          app.trigger("evenement:cle:show", idEvenement, idItem)

        layout.on "render", ->
          layout.getRegion('panelRegion').show(entete)
          layout.getRegion('itemsRegion').show(liste)
        app.regions.getRegion('main').show(layout)
      else
        app.trigger "not:found"
    ).fail( (response) ->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )
}

export controller = new Controller()
