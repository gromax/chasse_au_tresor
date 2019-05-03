import Marionette from 'backbone.marionette'
import AlertView from 'apps/common/alert_view.coffee'
import MissingView from 'apps/common/missing.coffee'
import { AccueilView, PanelView, SubItemCollectionView, Layout, CleCollectionView } from 'apps/parties/show/partie_joueur_view.coffee'

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

      panel = new PanelView { cle }
      panel.on "essai", (essai)->
        app.trigger("partie:show:cle", id, essai)

      idEssaiSelected = -1
      if data.item?
        # on a trouvé un item à afficher
        subItemsData = data.item.get("subItemsData")
        try
          d = JSON.parse(subItemsData)
          if not _.isArray(d) then d = []
        catch e
          d = []
        finally
          SubItemCollection = require("entities/itemsEvenement.coffee").SubItemCollection
          subItemsCollection = new SubItemCollection()
          subItemsCollection.add(d, {parse:true})
        vuePrincipale = new SubItemCollectionView { collection: subItemsCollection }
        itemSelected = data.essais.where({idItem:data.item.get("id")})[0]
        if itemSelected
          idEssaiSelected = itemSelected.get("id")
      else
        vuePrincipale = new AccueilView {
          model:partie
          evenement:evenement
          startCles:data.startCles
          cle
        }

        vuePrincipale.on "essai", (essai)->
          app.trigger("partie:show:cle", id, essai.normalize('NFD').replace(/[\u0300-\u036f]/g, ""))

      vueCles = new CleCollectionView { collection: data.essais, idSelected: data.item?.get("id") ? -1 }
      vueCles.on "cle:select", (v)->
        essai = v.model.get("essai").normalize('NFD').replace(/[\u0300-\u036f]/g, "")
        app.trigger("partie:show:cle", id, essai)

      vueCles.on "home", (v)->
        app.trigger("partie:show", id)

      layout.on "render", ()->
        layout.getRegion('panelRegion').show(panel)
        layout.getRegion('itemRegion').show(vuePrincipale)
        layout.getRegion('motsRegion').show(vueCles)
      app.regions.getRegion('main').show(layout)
    ).fail( (response) ->
      if response.status is 404
        view = new MissingView()
        app.regions.getRegion('main').show(view)
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
