import { MnObject } from 'backbone.marionette'
import { MissingView, AlertView, ListPanel, ListLayout } from 'apps/common/common_views.coffee'
import { PartiesList_RedacteurView, PartiesList_JoueurView } from 'apps/parties/list/parties_list_views.coffee'
import { EssaisCollectionView, ListEssaisPanel } from 'apps/parties/list/essais_list_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'
  listRedacteur: (criterion)->
    criterion = criterion ? ""
    app.trigger "header:loading", true
    listLayout = new ListLayout()
    listPanel = new ListPanel {
      title: "Parties"
      filterCriterion: criterion
    }
    channel = @getChannel()
    require "entities/dataManager.coffee"
    fetching = channel.request("custom:entities", ["parties"])
    $.when(fetching).done( (items)->
      listView = new PartiesList_RedacteurView {
        collection: items
      }

      listPanel.on "items:filter", (filterCriterion)->
        listView.trigger("set:filter:criterion", filterCriterion, { preventRender:false })
        app.trigger("evenements:filter", filterCriterion)

      listView.trigger("set:filter:criterion", criterion, { preventRender:false })

      listLayout.on "render", ()->
        listLayout.getRegion('panelRegion').show(listPanel)
        listLayout.getRegion('itemsRegion').show(listView)

      listView.on "item:show", (childView,e) ->
        model = childView.model
        idItem = model.get("id")
        app.trigger("partie:essais:list",idItem)

      app.regions.getRegion('main').show(listLayout)
    ).fail( (response)->
      if response.status is 401
        alert("Vous devez vous (re)connecter !")
        app.trigger("home:logout")
      else
        alertView = new AlertView()
        app.regions.getRegion('main').show(alertView)
    ).always( ->
      app.trigger "header:loading", false
    )

  listEssais: (idPartie) ->
    app.trigger "header:loading", true
    listLayout = new ListLayout()
    channel = @getChannel()
    require "entities/dataManager.coffee"
    fetching = channel.request("custom:essais", idPartie)
    $.when(fetching).done( (partie, evenement, essais, nomJoueur)->
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
        app.trigger "parties:filter", evenement.get("titre")

      listLayout.on "render", ()->
        listLayout.getRegion('panelRegion').show(listPanel)
        listLayout.getRegion('itemsRegion').show(listView)

      app.regions.getRegion('main').show(listLayout)
    ).fail( (response)->
      switch response.status
        when 401
          alert("Vous devez vous (re)connecter !")
          app.trigger("home:logout")
        when 404
          view = new MissingView()
          app.regions.getRegion('main').show(view)
        else
          alertView = new AlertView()
          app.regions.getRegion('main').show(alertView)
    ).always( ->
      app.trigger "header:loading", false
    )


  listJoueur: (criterion)->
    criterion = criterion ? ""
    app.trigger "header:loading", true
    listLayout = new ListLayout()
    listPanel = new ListPanel {
      title: "Mes parties"
      filterCriterion:criterion
    }
    channel = @getChannel()
    require "entities/dataManager.coffee"

    fetching = channel.request("custom:entities", ["parties"])
    $.when(fetching).done( (items)->
      listView = new PartiesList_JoueurView {
        collection: items
      }

      listView.on "item:select", (childView) ->
        id = childView.model.get("id")
        app.trigger "partie:show", id

      listPanel.on "items:filter", (filterCriterion)->
        listView.triggerMethod("set:filter:criterion", filterCriterion, { preventRender:false })
        app.trigger("evenements:filter", filterCriterion)

      listPanel.trigger "items:filter", filterCriterion

      listLayout.on "render", ()->
        listLayout.getRegion('panelRegion').show(listPanel)
        listLayout.getRegion('itemsRegion').show(listView)

      app.regions.getRegion('main').show(listLayout)
    ).fail( (response)->
      if response.status is 401
        alert("Vous devez vous (re)connecter !")
        app.trigger("home:logout")
      else
        alertView = new AlertView()
        app.regions.getRegion('main').show(alertView)
    ).always( ->
      app.trigger "header:loading", false
    )
}

export controller = new Controller()
