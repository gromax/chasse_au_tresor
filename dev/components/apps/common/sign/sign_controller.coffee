import { MnObject } from "backbone.marionette"
import { SignView } from "apps/common/sign/sign_view.coffee"
import { MissingView } from "apps/common/common_views.coffee"
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities"
  show: (options)->
    if app.Auth.get("logged_in")
      if typeof options?.callback is "function"
        options.callback()
      else
        app.trigger "home:show"
    else
      view = new SignView {
        signin: options?.signin
        desactiveModeChoiceButton: options?.desactiveModeChoiceButton
        showForgotten: options?.showForgotten
        showToggleButton: options?.showToggleButton
      }

      signinCallback = (data) ->
        openingSession = app.Auth.save(data)
        if openingSession
          app.trigger "loading:up"
          # En cas d'échec de connexion, l'api server renvoie une erreur
          $.when(openingSession).done( (response)->
            if typeof options?.callback is "function"
              options.callback()
            else
              app.trigger "home:show"
          ).fail( (response)->
            if response.status is 422
              view.triggerMethod("form:data:invalid", response.responseJSON.ajaxMessages);
            else
              alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/025]")
          ).always( ->
            app.trigger "loading:down"
          )
        else
          view.triggerMethod("form:data:invalid", app.Auth.validationError)

      signupCallback = (data) ->
        Joueur = require("entities/users.coffee").Item
        nJoueur = new Joueur()
        creatingSession = nJoueur.save(data)
        if creatingSession
          app.trigger("header:loading", true)
          $.when(creatingSession).done( (response)->
            # toutes les infos pour l'ouverture de session devraient être là
            view.options.signin = true
            view.options.username = data.username
            view.options.pwd = data.pwd
            view.render()
            signinCallback { username:data.username, pwd:data.pwd }
          ).fail( (response)->
            if response.status is 422
              view.triggerMethod("form:data:invalid", response.responseJSON.errors);
            else
              alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/025]")
          ).always( ()->
            app.trigger("header:loading", false)
          )
        else
          view.triggerMethod "form:data:invalid", nJoueur.validationError

      view.on "forgottenButton:click", (email) ->
        app.trigger("header:loading", true)
        sendingEmail = app.Auth.sendReinitEmail(email)
        $.when(sendingEmail).done( (response)->
          view.triggerMethod "form:data:invalid", [{ success:true, message:"Un email a été envoyé." }]
        ).fail( (response)->
          view.triggerMethod "form:data:invalid", [{ success:false, message:"Échec de l'envoi d'email." }]
        ).always( ()->
          app.trigger("header:loading", false)
        )

      view.on "form:submit", (data) ->
        if view.getOption("signin") is true
          signinCallback(data)
        else
          signupCallback(data)

      app.regions.getRegion('main').show(view)


  loginWithHash:(hash) ->
    openingSession = app.Auth.getSessionWithHash(hash)
    app.trigger("header:loading", true)
    $.when(openingSession).done( (response)->
      app.Auth.set _.extend(response, {logged_in:true})
      app.trigger "edit:me"
    ).fail( (response)->
      view = new MissingView { message: "Clé introuvable." }
      app.regions.getRegion('main').show(view)
    ).always( ()->
      app.trigger("header:loading", false)
    )

}

export controller = new Controller()
