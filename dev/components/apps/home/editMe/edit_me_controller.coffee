import { MnObject } from 'backbone.marionette'
import { EditUserView } from 'apps/common/edit_user_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'

  show: (criterion)->
    loggeUser = app.Auth

    view = new FormView {
      model: app.Auth
      showPwd: false
      showInfos: true
      showToggle: true
      generateTitle:true
      title: "Modifier mon compte"
    }

    view.on "form:submit", (data)->
      if _.has(data,"pwdConfirm")
        if data.pwd isnt data.pwdConfirm
          view.triggerMethod("form:data:invalid", { pwdConfirm:"Les mots de passe sont différents."})
          return null
        data = _.omit(data,"pwdConfirm")

      if app.Auth.get("rank") is "redacteur"
        Item = require("entities/redacteurs.coffee").Item
      else
        Item = require("entities/joueurs.coffee").Item
      item = new Item {
        username: app.Auth.get("username")
        id: app.Auth.get("id")
        nom: app.Auth.get("nom")
        pwd: app.Auth.get("pwd")
      }

      updatingItem = item.save(data)
      app.trigger("header:loading", true)
      if updatingItem
        $.when(updatingItem).done( ()->
          app.Auth.set {
            username: item.get("username")
            pwd: item.get("pwd")
            nom: item.get("nom")
          }
          app.trigger("home:show")
        ).fail( (response)->
          switch response.status
            when 422
              view.triggerMethod("form:data:invalid", response.responseJSON.errors)
            when 401
              alert("Vous devez vous (re)connecter !")
              app.trigger("home:logout")
            else
              alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/031]")
        ).always( ()->
          app.trigger("header:loading", false)
        )
      else
        @triggerMethod("form:data:invalid", item.validationError)

    app.regions.getRegion('main').show(view)
}

export controller = new Controller()
