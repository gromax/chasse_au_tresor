import Marionette from "backbone.marionette"
import SignupView from "apps/home/signup/signup_view.coffee"

app = require("app").app

Controller = Marionette.Object.extend {
  channelName: "entities"
  show: ->
    that = @
    view = new SignupView()
    view.on "form:submit", (data) ->
      Joueur = require("entities/joueurs.coffee").Item
      nJoueur = new Joueur()
      creatingSession = nJoueur.save(data)
      if creatingSession
        app.trigger("header:loading", true)
        $.when(creatingSession).done( (response)->
          openingSession = app.Auth.save _.pick(data,["pwd","email"])
          $.when(openingSession).done( (response)->
            app.trigger("home:show");
          ).fail( (response)->
            alert("Connexion impossible. Réessayez.")
          )
        ).fail( (response)->
          if response.status is 422
            view.triggerMethod("form:data:invalid", response.responseJSON.errors);
          else
            alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/025]")
        ).always( ()->
          app.trigger("header:loading", false)
        )
      else
        view.triggerMethod("form:data:invalid", nJoueur.validationError)

    app.regions.getRegion('main').show(view);
}

export controller = new Controller()
