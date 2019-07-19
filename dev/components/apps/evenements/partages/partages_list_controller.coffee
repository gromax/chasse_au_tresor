import { MnObject } from 'backbone.marionette'
import { ListPanel } from 'apps/common/common_views.coffee'
import { IEListPanel } from 'apps/evenements/edit/ie_list_views.coffee'
import { PartagesCollectionView, PartagesListLayout } from 'apps/evenements/partages/partages_list_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'
  show: (id,criterion)->
    app.trigger "loading:up"
    channel = @getChannel()
    require "entities/partages.coffee"
    fetching = channel.request("evenement:partages", id)
    $.when(fetching).done( (evenement, items)->
      listLayout = new PartagesListLayout()
      listView = new PartagesCollectionView {
        collection: items
      }

      entete = new IEListPanel {
        model: evenement
        partagesView: true
      }

      entete.on "navigate:parent", ->
        app.trigger "evenements:list"

      entete.on "navigate:partage", ->
        app.trigger "evenement:show", id

      listPanel = new ListPanel {
        idEvenement: id
        listView
        appTrigger: (view, criterion)->
          app.trigger "evenement:partage", view.getOption("idEvenement"), criterion
        title: "Partages"
        filterCriterion:criterion
        showAddButton:true
      }

      listLayout.on "render", ->
        listLayout.getRegion('enteteRegion').show(entete)
        listLayout.getRegion('panelRegion').show(listPanel)
        listLayout.getRegion('itemsRegion').show(listView)

      '''
      listPanel.on "item:new", ->
        Item = require("entities/redacteurs.coffee").Item
        newItem = new Item()
        view = new NewUserView {
          model: newItem
          title: "Nouveau rédacteur"
          listView: listView
        }
        app.regions.getRegion('dialog').show(view)
      '''

      app.regions.getRegion('main').show(listLayout)
    ).fail( (response)->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )
}

export controller = new Controller()
