app = require('app').app
Router = Backbone.Router.extend {
  routes: {
    "evenements(/filter/criterion::criterion)": "list"
    "evenement::id": "show"
    "evenement::id/edit": "edit"
    "evenement::id/password": "editPwd"
    "evenement::idE/cle::id" : "showItemEvenement"
    "evenement::id/partages(/filter/criterion::criterion)" : "listPartages"
  }

  show: (id) ->
    rank = app.Auth.get("rank")
    if (rank is "root") or (rank is "redacteur")
      require("apps/evenements/edit/ie_list_controller.coffee").controller.show(id)
    else
      app.trigger "not:found"

  list: (criterion) ->
    rank = app.Auth.get("rank")
    if (rank is "root") or (rank is "redacteur")
      require("apps/evenements/list/evenements_list_controller.coffee").controller.listRedacteur(criterion)
    else if (rank is "joueur")
      require("apps/evenements/list/evenements_list_controller.coffee").controller.listJoueur(criterion)
    else
      app.trigger "not:found"

  showItemEvenement: (idE,id) ->
    rank = app.Auth.get("rank")
    if (rank is "root") or (rank is "redacteur")
      require("apps/evenements/edit/sub_ie_list_controller.coffee").controller.show(id)
    else
      app.trigger "not:found"

  listPartages: (id, criterion) ->
    rank = app.Auth.get("rank")
    if (rank is "root") or (rank is "redacteur")
      require("apps/evenements/partages/partages_list_controller.coffee").controller.show(id,criterion)
    else
      app.trigger "not:found"
}

router = new Router()

app.on "evenements:list", ()->
  app.navigate("evenements")
  router.list()

app.on "evenement:partages", (id)->
  app.navigate "evenement:#{id}/partages"
  router.listPartages(id)

app.on "evenement:partage:filter", (id,criterion)->
  if criterion
    app.navigate "evenement:#{id}/partages/filter:#{criterion}"
  else
    app.navigate "evenement:#{id}/partages"

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
