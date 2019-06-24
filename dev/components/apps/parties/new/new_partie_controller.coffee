import { MnObject } from 'backbone.marionette'
import { NewPartieView } from 'apps/parties/new/new_partie_view.coffee'
import { MissingView, AlertView } from 'apps/common/common_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'
  show: (id)->
    app.trigger "header:loading", true
    channel = @getChannel()
    require "entities/dataManager.coffee"
    fetching = channel.request("custom:entities", ["evenements"])
    $.when(fetching).done( (items)->
      evenement = items.get(id)
      if evenement isnt  undefined
        view = new NewPartieView { model:evenement }
        view.on "partie:continue", (id)->
          app.trigger "partie:show", id

        view.on "partie:start", (id)->
          Item = require("entities/parties.coffee").Item
          partie = new Item { idEvenement:id }
          savingPartie = partie.save()
          app.trigger("header:loading", true)
          $.when(savingPartie).done( ()->
            app.trigger "partie:show", partie.get("id")
          ).fail( (response)->
            switch response.status
              when 401
                alert("Vous devez vous (re)connecter !")
                view.trigger("dialog:close")
                app.trigger("home:logout")
              else
                alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur")
          ).always(()->
            app.trigger("header:loading", false)
          )
        app.regions.getRegion('main').show(view)
      else
        view = new MissingView()
        app.regions.getRegion('main').show(view)
    ).fail( (response) ->
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
