import { MnObject } from 'backbone.marionette'
import { MissingView, AlertView } from 'apps/common/common_views.coffee'
import { PartieAccueilView, PartiePanelView, PartieLayout, ClesCollectionView } from 'apps/parties/show/partie_joueur_view.coffee'
import { SubIECollectionView } from 'apps/evenements/edit/sub_ie_list_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities",
  show: (options) ->
    app.trigger "header:loading", true
    require "entities/dataManager.coffee"
    channel = @getChannel()
    fetchingData = channel.request("custom:partie", options)
    $.when(fetchingData).done( (data)->
      partie = data.partie
      id = partie.get("id")
      if options.cle
        cle = options.cle
      else
        cle = ""
      evenement = data.evenement
      layout = new PartieLayout()
      panel = new PartiePanelView { cle }
      panel.on "essai", (essai)->
        app.trigger("partie:show:cle", id, essai.normalize('NFD').replace(/[\u0300-\u036f]/g, ""))

      panel.on "essai:gps", ->
        options = {
          enableHighAccuracy: true
          timeout: 5000
          maximumAge: 0
        }

        errorFct = (err) ->
          app.trigger("header:loading", false)
          console.warn("ERREUR (#{err.code}): #{err.message}")

        successFct = (pos) ->
          app.trigger("header:loading", false)
          crd = pos.coords;
          app.trigger("partie:show:cle", id, "gps=#{crd.latitude},#{crd.longitude},#{Math.round(crd.accuracy)}")
        app.trigger("header:loading", true)
        navigator.geolocation.getCurrentPosition(successFct, errorFct, options)


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
        vuePrincipale = new SubIECollectionView { collection: subItemsCollection }
        vuePrincipale.on "subItem:click:cle", (cible)->
          app.trigger "partie:show:cle", id, cible.normalize('NFD').replace(/[\u0300-\u036f]/g, "")
      else
        vuePrincipale = new PartieAccueilView {
          model:partie
          evenement:evenement
          cle
        }

      vueCles = new ClesCollectionView { collection: data.essais, idSelected: data.item?.get("id") ? -1 }
      vueCles.on "cle:select", (v)->
        app.trigger "partie:show:cle", id, v.model.get("essai").normalize('NFD').replace(/[\u0300-\u036f]/g, "")

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
        app.trigger "home:logout"
      else
        alertView = new AlertView()
        app.regions.getRegion('main').show(alertView)
    ).always( () ->
      app.trigger("header:loading", false)
    )
}

export controller=new Controller()
