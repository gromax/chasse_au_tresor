app = require('app').app
Router = Backbone.Router.extend {
  routes: {
    "parties(/filter/criterion::criterion)": "list"
    "partie::id(/cle::cle)": "show"
    "partie/hash::hash": "showHash"
    "partie/start::id": "start"
    "partie::id/essais": "showEssaisPartie"
  }

  list: (criterion) ->
    rank = app.Auth.get("rank")
    if (rank is "root") or (rank is "redacteur")
      require("apps/parties/list/parties_list_controller.coffee").controller.listRedacteur(criterion)
    else if (rank is "joueur")
      require("apps/parties/list/parties_list_controller.coffee").controller.listJoueur(criterion)

  showEssaisPartie: (idPartie)->
    rank = app.Auth.get("rank")
    if (rank is "redacteur")
      require("apps/parties/list/parties_list_controller.coffee").controller.listEssais(idPartie)

  show: (id, cle) ->
    rank = app.Auth.get("rank")
    if (rank is "joueur")
      if typeof cle is "string" then cle = cle.replace(/__/g," ")
      require("apps/parties/show/partie_joueur_controller.coffee").controller.show({id, cle})

  showHash: (hash) ->
    rank = app.Auth.get("rank")
    if rank is "off"
      cb = () ->
        app.trigger "partie:show:hash", hash
      require("apps/common/sign/sign_controller.coffee").controller.show({signin:true, desactiveModeChoiceButton:true, adm:0, callback:cb, showToggleButton:true })
    if rank is "joueur"
      require("apps/parties/show/partie_joueur_controller.coffee").controller.show({hash})

  start: (id) ->
    rank = app.Auth.get("rank")
    if (rank is "joueur")
      require("apps/parties/new/new_partie_controller.coffee").controller.show(id)
}

router = new Router()

app.on "parties:list", ()->
  app.navigate("parties")
  router.list()

app.on "parties:filter", (criterion) ->
  if criterion
    app.navigate "parties/filter/criterion:#{criterion}"
  else
    app.navigate "parties"

app.on "partie:start", (id) ->
  app.navigate "partie/start:#{id}"
  router.start(id)

app.on "partie:show", (id) ->
  app.navigate "partie:#{id}"
  router.show(id,"")

app.on "partie:show:cle", (id,cle) ->
  app.navigate "partie:#{id}/cle:#{cle.replace(/\s/g,"__")}"
  router.show(id,cle)

app.on "partie:show:hash", (hash) ->
  app.navigate "partie/hash:#{hash}"
  router.showHash(hash)

app.on "partie:essais:list", (id) ->
  app.navigate "partie:#{id}/essais"
  router.showEssaisPartie(id)
