import { View } from 'backbone.marionette'
import { app } from 'app'
import home_joueur_tpl from 'templates/home/show/joueur.tpl'
import home_redacteur_tpl from 'templates/home/show/redacteur.tpl'
import home_root_tpl from 'templates/home/show/root.tpl'
import home_off_tpl from 'templates/home/show/off.tpl'

JoueurHomeView = View.extend {
  template: home_joueur_tpl
  triggers: {
    "click a.js-edit-me": "edit:me"
    "click a.js-evenements": "evenements:disponibles:list"
    "click a.js-parties": "parties:list"
  }

  onEditMe: (e) ->
    app.trigger "edit:me"

  onEvenementsDisponiblesList: (e) ->
    app.trigger "evenements:disponibles:list"

  onPartiesList: (e) ->
    app.trigger "parties:list"
}

RedacteurHomeView = View.extend {
  template: home_redacteur_tpl
  triggers: {
    "click a.js-edit-me": "edit:me"
    "click a.js-evenements": "evenements:list"
    "click a.js-parties": "parties:list"
  }

  onEditMe: (e) ->
    app.trigger "edit:me"

  onEvenementsList: (e) ->
    app.trigger "evenements:list"

  onPartiesList: (e) ->
    app.trigger "parties:list"
}

RootHomeView = View.extend {
  template: home_root_tpl
  triggers: {
    "click a.js-redacteurs": "redacteurs:list"
    "click a.js-evenements": "evenements:list"
    "click a.js-joueurs": "joueurs:list"
    "click a.js-parties": "parties:list"
  }

  onRedacteursList: (e) ->
    app.trigger "redacteurs:list"

  onEvenementsList: (e) ->
    app.trigger "evenements:list"

  onJoueursList: (e) ->
    app.trigger "joueurs:list"

  onPartiesList: (e) ->
    app.trigger "parties:list"
}

OffHomeView = View.extend {
  template: home_off_tpl
  triggers: {
    "click a.js-login": "home:login"
    "click a.js-signup": "home:signup"
  }

  onHomeLogin: (e) ->
    app.trigger("home:login");

  onHomeSignup: (e) ->
    app.trigger("home:signup");

  templateContext: ->
    {
      version: app.version
    }
}

export { JoueurHomeView, RedacteurHomeView, RootHomeView, OffHomeView }
