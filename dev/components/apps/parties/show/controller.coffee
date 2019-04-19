import Marionette from 'backbone.marionette'
import AlertView from 'apps/common/alert_view.coffee'
import MissingView from 'apps/common/missing.coffee'
import { AccueilView, PanelView, Layout } from 'apps/parties/show/partie_joueur_view.coffee'

app = require('app').app

Controller = Marionette.Object.extend {
  channelName: "entities",
  show: (id, cle) ->
    app.trigger("header:loading", true)

    require "entities/dataManager.coffee"
    channel = @getChannel()

    fetchingData = channel.request("custom:partie", id, cle)
    $.when(fetchingData).done( (data)->
      partie = data.partie
      evenement = data.evenement
      layout = new Layout()
      app.Ariane.add([{ text:evenement.get("titre"), e:"partie:show", data:[id], link:"partie:#{id}"}])
      vuePrincipale = new AccueilView {model:partie, evenement:evenement, startCles:data.startCles, cle }
      panel = new PanelView { cle }

      panel.on "essai", (essai)->
        app.trigger("partie:show:cle", id, essai)

      vuePrincipale.on "essai", (essai)->
        app.trigger("partie:show:cle", id, essai)

      layout.on "render", ()->
        layout.getRegion('panelRegion').show(panel)
        layout.getRegion('itemRegion').show(vuePrincipale)
      app.regions.getRegion('main').show(layout)
    ).fail( (response) ->
      if response.status is 404
        view = new MissingView()
        app.regions.getRegion('main').show(view)
        app.Ariane.add([{ text:"Inconnu"}])
      else if response.status is 401
        alert("Vous devez vous (re)connecter !")
        app.trigger("home:logout")
      else
        alertView = new AlertView()
        app.regions.getRegion('main').show(alertView)
    ).always( () ->
      app.trigger("header:loading", false)
    )
}

export controller=new Controller()
