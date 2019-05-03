app = require('app').app
Router = Backbone.Router.extend {
  routes: {
    "evenements(/filter/criterion::criterion)": "list"
    "evenement::id": "show"
    "evenement::id/edit": "edit"
    "evenement::id/password": "editPwd"
    "evenement::idE/cle::id" : "showItemEvenement"
  }

  show: (id) ->
    rank = app.Auth.get("rank")
    if (rank is "redacteur") or (rank is "joueur")
      require("apps/evenements/edit/controller.coffee").controller.show(id)

  list: (criterion) ->
    rank = app.Auth.get("rank")
    if (rank is "root") or (rank is "redacteur")
      require("apps/evenements/list/controller.coffee").controller.listRedacteur(criterion)
    else if (rank is "joueur")
      require("apps/evenements/list/controller.coffee").controller.listJoueur(criterion)

  showItemEvenement: (idE,id) ->
    rank = app.Auth.get("rank")
    if (rank is "root") or (rank is "redacteur")
      require("apps/evenements/edit/controller.coffee").controller.showItem(id)
}

router = new Router()

app.on "evenements:list", ()->
  app.navigate("evenements")
  router.list()

app.on "evenements:filter", (criterion) ->
  if criterion
    app.navigate "evenements/filter/criterion:#{criterion}"
  else
    app.navigate "evenements"

app.on "evenement:show", (id) ->
  app.navigate "evenement:#{id}"
  router.show(id)

app.on "evenement:cle:show", (idE, id) ->
  app.navigate "evenement:#{idE}/cle:#{id}"
  router.showItemEvenement(idE,id)
