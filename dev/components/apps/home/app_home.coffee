app = require('app').app

Router = Backbone.Router.extend {
  routes: {
    "" : "showHome"
    "home" : "showHome"
    "login" : "showSign"
    "signup" : "showSignUp"
    "edit-me" : "showEditMe"
    "redacteur/forgotten/:hash": "redacteurLoginWithHash"
    "joueur/forgotten/:hash": "joueurLoginWithHash"
  }

  showHome: ->
    require("apps/home/show/home_show_controller.coffee").controller.showHome()

  showSign: ->
    if app.Auth.get("logged_in")
      require("apps/home/show/home_show_controller.coffee").controller.showHome()
    else
      require("apps/common/sign/sign_controller.coffee").controller.show({ signin:true, showForgotten:true })

  showSignUp: ->
    if app.Auth.get("logged_in")
      require("apps/home/show/home_show_controller.coffee").controller.showHome()
    else
      require("apps/common/sign/sign_controller.coffee").controller.show({ signin:false })

  redacteurLoginWithHash: (hash) ->
    if app.Auth.get("logged_in")
      require("apps/home/show/home_show_controller.coffee").controller.showHome()
    else
      require("apps/common/sign/sign_controller.coffee").controller.loginWithHash(hash, true)

  joueurLoginWithHash: (hash) ->
    if app.Auth.get("logged_in")
      require("apps/home/show/home_show_controller.coffee").controller.showHome()
    else
      require("apps/common/sign/sign_controller.coffee").controller.loginWithHash(hash, false)


  logout: ->
    if app.Auth.get("logged_in")
      closingSession = app.Auth.destroy()
      $.when(closingSession).done( (response)->
        # En cas d'échec de connexion, l'api server renvoie une erreur
        # Le delete n'occasione pas de raffraichissement des données
        # Il faut donc le faire manuellement
        app.Auth.refresh(response)
        require("apps/home/show/home_show_controller.coffee").controller.showHome()
      ).fail( (response)->
        alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/024]");
      )

  showEditMe: ->
    if not app.Auth.get("logged_in") or (app.Auth.get("rank") is "root")
      require("apps/home/show/home_show_controller.coffee").controller.showHome()
    else
      require("apps/home/editMe/edit_me_controller.coffee").controller.show()

  notFound: ->
    require("apps/home/show/home_show_controller.coffee").controller.showNotFound()

}

router = new Router()

app.on "home:show", ->
  app.navigate("home")
  router.showHome()

app.on "home:login", ->
  app.navigate("login")
  router.showSign()

app.on "home:signup", ->
  app.navigate("signin")
  router.showSignUp()

app.on "home:logout", ->
  router.logout()
  app.trigger("home:show")

app.on "edit:me", ->
  app.navigate("edit-me")
  router.showEditMe()

app.on "not:found", ->
  router.notFound()
