import Marionette from 'backbone.marionette'
import { MissingView, AlertView } from 'apps/common/commons_view.coffee'
import { Layout, Panel } from 'apps/common/list.coffee'
import { RedacteurListView, JoueurListView } from 'apps/parties/list/view_parties.coffee'
import { EssaisListView, EssaisEntetePanel } from 'apps/parties/list/view_essais.coffee'

app = require('app').app

Controller = Marionette.Object.extend {
  channelName: 'entities'

  listRedacteur: (criterion)->
    criterion = criterion ? ""
    app.trigger("header:loading", true)
    listLayout = new Layout()
    listPanel = new Panel {
      filterCriterion: criterion
      title: "Parties"
    }

    channel = @getChannel()

    require "entities/dataManager.coffee"
    Item = require("entities/parties.coffee").Item

    fetching = channel.request("custom:entities", ["parties"])
    $.when(fetching).done( (items)->
      listView = new RedacteurListView {
        collection: items
        filterCriterion: criterion
      }

      listPanel.on "items:filter", (filterCriterion)->
        listView.triggerMethod("set:filter:criterion", filterCriterion, { preventRender:false })
        app.trigger("evenements:filter", filterCriterion)

      listLayout.on "render", ()->
        listLayout.getRegion('panelRegion').show(listPanel)
        listLayout.getRegion('itemsRegion').show(listView)

      listView.on "item:show", (childView,e) ->
        model = childView.model
        idItem = model.get("id")
        app.trigger("partie:essais:list",idItem)

      listView.on "item:delete", (childView,e)->
        model = childView.model
        idItem = model.get("id")
        if confirm("Supprimer la partie « ##{idItem} - #{model.get('dateDebut_fr')} » ?")
          destroyRequest = model.destroy()
          app.trigger("header:loading", true)
          $.when(destroyRequest).done( ()->
            childView.remove()
          ).fail( (response)->
            alert("Erreur. Essayez à nouveau !")
          ).always( ()->
            app.trigger("header:loading", false)
          )
      app.regions.getRegion('main').show(listLayout)
    ).fail( (response)->
      if response.status is 401
        alert("Vous devez vous (re)connecter !")
        app.trigger("home:logout")
      else
        alertView = new AlertView()
        app.regions.getRegion('main').show(alertView)
    ).always( ()->
      app.trigger("header:loading", false)
    )

  listEssais: (idPartie) ->
    app.trigger("header:loading", true)
    listLayout = new Layout()

    channel = @getChannel()

    require "entities/dataManager.coffee"

    fetching = channel.request("custom:essais", idPartie)
    $.when(fetching).done( (partie, evenement, essais, nomJoueur)->
      listPanel = new EssaisEntetePanel {
        partie
        evenement
        essais
        nomJoueur
      }
      listView = new EssaisListView {
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
    ).always( ()->
      app.trigger("header:loading", false)
    )


  listJoueur: (criterion)->
    criterion = criterion ? ""
    app.trigger("header:loading", true)
    listLayout = new Layout()
    listPanel = new Panel {
      title: "Mes parties"
      filterCriterion:criterion
    }

    channel = @getChannel()

    require "entities/dataManager.coffee"
    Item = require("entities/parties.coffee").Item

    fetching = channel.request("custom:entities", ["parties"])
    $.when(fetching).done( (items)->
      listView = new JoueurListView {
        collection: items
        filterCriterion: criterion
      }

      listView.on "item:select", (childView) ->
        id = childView.model.get("id")
        app.trigger "partie:show", id

      listPanel.on "items:filter", (filterCriterion)->
        listView.triggerMethod("set:filter:criterion", filterCriterion, { preventRender:false })
        app.trigger("evenements:filter", filterCriterion)

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
    ).always( ()->
      app.trigger("header:loading", false)
    )
}

export controller = new Controller()
