import { MnObject } from 'backbone.marionette'
import { MissingView, AlertView } from 'apps/common/common_views.coffee'
import { PartieAccueilView, PartiePanelView, PartieLayout, ClesCollectionView } from 'apps/parties/show/partie_joueur_view.coffee'
import { SubIECollectionView } from 'apps/evenements/edit/sub_ie_list_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities",
  show: (options) ->
    app.trigger "loading:up"
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
      panel = new PartiePanelView {
        cle
        actif: evenement.get("actif")
      }
      panel.on "essai", (essai)->
        app.trigger("partie:show:cle", id, essai.normalize('NFD').replace(/[\u0300-\u036f\'\s\\]/g, ""))

      panel.on "essai:gps", ->
        options = {
          enableHighAccuracy: true
          timeout: 5000
          maximumAge: 0
        }

        errorFct = (err) ->
          app.trigger "loading:up"
          console.warn("ERREUR (#{err.code}): #{err.message}")

        successFct = (pos) ->
          app.trigger "loading:down"
          crd = pos.coords;
          app.trigger("partie:show:cle", id, "gps=#{crd.latitude},#{crd.longitude},#{Math.round(crd.accuracy)}")
        app.trigger "loading:up"
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
        # Dans ce cas je souhaite vérifier si la clé fausse est sauvegardée
        cleSaved = true
        if cle isnt ""
          cleSaved = data.essais.filter({essai:cle}).length>0

        vuePrincipale = new PartieAccueilView {
          model:partie
          evenement:evenement
          cle
          cleSaved
        }


      vueCles = new ClesCollectionView {
        collection: data.essais
        idSelected: data.item?.get("id") ? -1
        erreursVisibles: app.user_options.erreursVisibles
        showErreursVisiblesButton: evenement.get "sauveEchecs"
      }

      clesFilterFct = (view, index, children) ->
        view.model.get("idItem") >= 0
      unless app.user_options.erreursVisibles
        vueCles.setFilter clesFilterFct, {}
      vueCles.on "cle:select", (v)->
        app.trigger "partie:show:cle", id, v.model.get("essai").normalize('NFD').replace(/[\u0300-\u036f]/g, "")
      vueCles.on "erreurs:visibles:toggle", ->
        app.user_options.erreursVisibles = not app.user_options.erreursVisibles
        if app.user_options.erreursVisibles
          vueCles.removeFilter {}
        else
          vueCles.setFilter clesFilterFct, {}

      vueCles.on "cles:test:need:refresh", ->
        fetchingCount = channel.request("custom:count:essais", id)
        app.trigger "loading:up"
        $.when(fetchingCount).done( (cnt)->
          if cnt+vueCles.collection.where({idItem:-1}).length isnt vueCles.children.length
            vueCles.triggerMethod "show:message:news"
        ).fail( (response)->
          console.warn "Erreur de rechargement"
          vueCles.stopRefresh = true
        ).always(->
          app.trigger "loading:down"
        )

      vueCles.on "click:refresh:button", ->
        app.trigger "partie:show:cle", id, cle

      vueCles.on "destroy", ->
        clearInterval @testNeedRefreshClesInterval

      testNeedRefreshClesFct= ->
        if vueCles.stopRefresh
          clearInterval vueCles.testNeedRefreshClesInterval
        else
          vueCles.trigger "cles:test:need:refresh"

      vueCles.testNeedRefreshClesInterval = setInterval(testNeedRefreshClesFct, 30000)

      layout.on "render", ()->
        layout.getRegion('panelRegion').show(panel)
        layout.getRegion('itemRegion').show(vuePrincipale)
        layout.getRegion('motsRegion').show(vueCles)
      app.regions.getRegion('main').show(layout)
    ).fail( (response) ->
      if response.status is 404
        view = new MissingView {
          message: "<ul><li>Vous cherchez une partie qui n'existe pas,</li><li>ou peut-être un événement qui n'est pas encore activé. Dans ce cas, essayez plus tard.</li></ul>"
        }
        app.regions.getRegion('main').show(view)
      else if response.status is 401
        alert("Vous devez vous (re)connecter !")
        app.trigger "home:logout"
      else
        alertView = new AlertView()
        app.regions.getRegion('main').show(alertView)
    ).always( ->
      app.trigger "loading:down"
    )
}

export controller=new Controller()
