import { MnObject } from 'backbone.marionette'
import { NewPartieView } from 'apps/parties/new/new_partie_view.coffee'
import { app } from 'app'

mainFct= (evenement)->
  if evenement
    view = new NewPartieView { model:evenement }
    view.on "partie:continue", (id)->
      app.trigger "partie:show", id

    view.on "partie:start", (id)->
      Item = require("entities/parties.coffee").Item
      partie = new Item { idEvenement:id }
      savingPartie = partie.save()
      app.trigger "loading:up"
      $.when(savingPartie).done( ->
        app.trigger "partie:show", partie.get("id")
      ).fail( (response)->
        switch response.status
          when 401
            alert("Vous devez vous (re)connecter !")
            view.trigger("dialog:close")
            app.trigger("home:logout")
          else
            alert "Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur"
      ).always( ->
        app.trigger "loading:down"
      )
    app.regions.getRegion('main').show(view)
  else
    app.trigger "not:found"

Controller = MnObject.extend {
  channelName: 'entities'
  show: (id)->
    app.trigger "loading:up"
    channel = @getChannel()
    require "entities/dataManager.coffee"
    fetching = channel.request("custom:entities", ["evenements"])
    $.when(fetching).done( (items)->
      evenement = items.get(id)
      mainFct evenement
    ).fail( (response) ->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )
  showHash: (hash)->
    app.trigger "loading:up"
    channel = @getChannel()
    require "entities/evenements.coffee"
    fetching = channel.request("evenement:hash", hash)
    $.when(fetching).done( mainFct
    ).fail( (response) ->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )
}

export controller = new Controller()
