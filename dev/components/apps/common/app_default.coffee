import { app } from 'app'
import { AlertView } from 'apps/common/common_views.coffee'

Router = Backbone.Router.extend {
  routes: {
  }

  showMessageSuccess: (message) ->
    view = new AlertView {
      type: "success"
      message: message
      title: "Succès !"
    }
    app.regions.getRegion('message').show(view)

  showMessageError: (message) ->
    view = new AlertView {
      message: message
    }
    app.regions.getRegion('message').show(view)


}

router = new Router()

app.on "show:message:success", (message)->
  router.showMessageSuccess(message)

app.on "show:message:error", (message)->
  router.showMessageError(message)
