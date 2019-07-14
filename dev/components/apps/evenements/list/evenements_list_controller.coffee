import { MnObject } from 'backbone.marionette'
import { ListPanel, ListLayout } from 'apps/common/common_views.coffee'
import { EvenementsCollectionView_Redacteur, EvenementsCollectionView_Joueur, EditEvenementView } from 'apps/evenements/list/evenements_list_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'

  listRedacteur: (criterion)->
    criterion = criterion ? ""
    app.trigger "loading:up"
    channel = @getChannel()
    require "entities/dataManager.coffee"
    fetching = channel.request("custom:entities", ["evenements"])
    $.when(fetching).done( (items)->
      listLayout = new ListLayout()
      listView = new EvenementsCollectionView_Redacteur {
        collection: items
        filterCriterion: criterion
      }

      listPanel = new ListPanel {
        listView
        title: "Événements"
        filterCriterion:criterion
        showAddButton: app.Auth.get("rank") is "redacteur"
      }

      listLayout.on "render", ->
        listLayout.getRegion('panelRegion').show(listPanel)
        listLayout.getRegion('itemsRegion').show(listView)

      listPanel.on "item:new", ->
        Item = require("entities/evenements.coffee").Item
        view = new EditEvenementView {
          model: new Item()
          collection: items
          listView: listView
          title: "Nouvel événement"
        }
        app.regions.getRegion('dialog').show(view)

      listView.on "item:edit", (childView, args)->
        model = childView.model
        view = new EditEvenementView {
          model: model
          itemView: childView
          title: "Modification de ##{model.get('id')} : #{model.get('nom')}"
        }
        app.regions.getRegion('dialog').show(view)

      listView.on "item:activation:toggle", (childView)->
        childView.trigger "toggle:attribute", "actif"

      listView.on "item:visible:toggle", (childView)->
        childView.trigger "toggle:attribute", "visible"

      listView.on "item:sauveEchecs:toggle", (childView)->
        childView.trigger "toggle:attribute", "sauveEchecs"

      listView.on "item:show", (childView,e) ->
        id = childView.model.get("id")
        app.trigger("evenement:show", id)
      app.regions.getRegion('main').show(listLayout)
    ).fail( (response)->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )

  listJoueur: (criterion)->
    criterion = criterion ? ""
    app.trigger "loading:up"
    channel = @getChannel()
    require "entities/dataManager.coffee"
    fetching = channel.request("custom:entities", ["evenements"])
    $.when(fetching).done( (items)->
      listLayout = new ListLayout()

      listView = new EvenementsCollectionView_Joueur {
        collection: items
        filterCriterion: criterion
      }

      listPanel = new ListPanel {
        listView
        title: "Événements"
        filterCriterion: criterion
        showAddButton: false
      }

      listLayout.on "render", ->
        listLayout.getRegion('panelRegion').show(listPanel)
        listLayout.getRegion('itemsRegion').show(listView)

      listView.on "item:select", (childView,e) ->
        id = childView.model.get("id")
        app.trigger("partie:start", id)
      app.regions.getRegion('main').show(listLayout)
    ).fail( (response)->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )
}

export controller = new Controller()
