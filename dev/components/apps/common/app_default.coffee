import { app } from 'app'
import { AlertView, MissingView } from 'apps/common/common_views.coffee'

Router = Backbone.Router.extend {
  routes: {
    '*path': 'notFound'
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

  notFound: ->
    view = new AlertView {
      message: "Page introuvable"
      dismiss: false
    }
    app.regions.getRegion('main').show(view)

  dataFetchFail: ->
    switch response.status
      when 401
        alert("Vous devez vous (re)connecter !")
        app.trigger("home:logout")
      when 404
        view = new MissingView()
        app.regions.getRegion('main').show(view)
      else
        view = new AlertView()
        app.regions.getRegion('main').show(view)
}

router = new Router()

app.on "show:message:success", (message)->
  router.showMessageSuccess(message)

app.on "show:message:error", (message) ->
  router.showMessageError(message)

app.on "data:fetch:fail", (response) ->
  router.dataFetchFail response

app.on "not:found", ->
  router.notFound()

app.on "loading:up", ->
  app.ajaxCount++
  app.trigger "header:loading", true

app.on "loading:down", ->
  app.ajaxCount--
  if app.ajaxCount is 0
    app.trigger "header:loading", false
