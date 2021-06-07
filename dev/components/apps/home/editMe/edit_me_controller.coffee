import { MnObject } from 'backbone.marionette'
import { SubmitClicked, EditItem } from 'apps/common/behaviors.coffee'
import { EditUserView } from 'apps/common/edit_user_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'

  show: (criterion)->
    loggeUser = app.Auth

    Item = require("entities/users.coffee").Item
    item = new Item {
      username: app.Auth.get("username")
      id: app.Auth.get("id")
      nom: app.Auth.get("nom")
      pwd: app.Auth.get("pwd")
      isredac: app.Auth.get("rank") is "redacteur"
    }

    view = new EditUserView {
      model: item
      showPwd: false
      showInfos: true
      showToggle: true
      generateTitle:true
      behaviors: [SubmitClicked, EditItem]
      title: "Modifier mon compte"
      onSuccess: (model, data)->
        app.Auth.set(data) # met à jour nom, prénom et pref
        app.trigger "show:message:success", "Votre compte a été modifié"
    }

    app.regions.getRegion('main').show(view)
}

export controller = new Controller()
