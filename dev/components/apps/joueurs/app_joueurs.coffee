import { app } from 'app'
Router = Backbone.Router.extend {
  routes: {
    "joueurs(/filter/criterion::criterion)": "list"
    "joueur::id": "show"
    "joueur::id/edit": "edit"
    "joueur::id/password": "editPwd"
  }

  list: (criterion) ->
    rank = app.Auth.get("rank")
    if rank is "root"
      require("apps/joueurs/list/joueurs_list_controller.coffee").controller.list(criterion)
}

router = new Router()

app.on "joueurs:list", ()->
  app.navigate("joueurs")
  router.list()

app.on "joueurs:filter", (criterion) ->
  if criterion
    app.navigate "joueurs/filter/criterion:#{criterion}"
  else
    app.navigate "joueurs"
