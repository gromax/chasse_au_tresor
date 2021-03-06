import { MnObject } from 'backbone.marionette'
import { ListPanel, ListLayout } from 'apps/common/common_views.coffee'
import { PartiesList_RedacteurView, PartiesList_JoueurView } from 'apps/parties/list/parties_list_views.coffee'
import { EssaisCollectionView, ListEssaisPanel } from 'apps/parties/list/essais_list_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'
  listRedacteur: (criterion)->
    app.trigger "loading:up"

    channel = @getChannel()
    require "entities/dataManager.coffee"
    fetching = channel.request("custom:entities", ["parties"])
    $.when(fetching).done( (items)->
      listLayout = new ListLayout()
      listView = new PartiesList_RedacteurView {
        collection: items
        filterCriterion: criterion
      }
      listPanel = new ListPanel {
        listView
        appTrigger:"parties:filter"
        title: "Parties"
        filterCriterion: criterion
      }

      listLayout.on "render", ()->
        listLayout.getRegion('panelRegion').show(listPanel)
        listLayout.getRegion('itemsRegion').show(listView)

      listView.on "item:show", (childView,e) ->
        model = childView.model
        idItem = model.get("id")
        app.trigger("partie:essais:list",idItem)

      listView.on "item:event:filter", (eventName) ->
        app.trigger "parties:list", eventName

      app.regions.getRegion('main').show(listLayout)
    ).fail( (response)->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )

  listEssais: (idPartie) ->
    app.trigger "loading:up"
    channel = @getChannel()
    require "entities/dataManager.coffee"
    fetching = channel.request("custom:essais", idPartie)
    $.when(fetching).done( (partie, evenement, essais, nomJoueur)->
      listLayout = new ListLayout()
      listPanel = new ListEssaisPanel {
        partie
        evenement
        essais
        nomJoueur
      }
      listView = new EssaisCollectionView {
        collection: essais
      }

      listPanel.on "navigate:parent", ->
        app.trigger "parties:list", evenement.get("titre")

      listView.on "remove:child", ->
        listPanel.render()

      listLayout.on "render", ()->
        listLayout.getRegion('panelRegion').show(listPanel)
        listLayout.getRegion('itemsRegion').show(listView)

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

    fetching = channel.request("custom:entities", ["parties"])
    $.when(fetching).done( (items)->
      listLayout = new ListLayout()
      listView = new PartiesList_JoueurView {
        collection: items
        filterCriterion: criterion
      }
      listPanel = new ListPanel {
        listView
        title: "Mes parties"
        filterCriterion:criterion
      }

      listView.on "item:select", (childView) ->
        id = childView.model.get("id")
        app.trigger "partie:show", id

      listLayout.on "render", ()->
        listLayout.getRegion('panelRegion').show(listPanel)
        listLayout.getRegion('itemsRegion').show(listView)

      app.regions.getRegion('main').show(listLayout)
    ).fail( (response)->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )
}

export controller = new Controller()
