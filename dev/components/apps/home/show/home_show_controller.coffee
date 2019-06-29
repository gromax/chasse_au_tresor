import { MnObject } from 'backbone.marionette'
import { AlertView } from 'apps/common/common_views.coffee'
import { JoueurHomeView, RedacteurHomeView, RootHomeView, OffHomeView } from 'apps/home/show/home_views.coffee'
import { app } from 'app'

Controller = MnObject .extend {
  channelName: "entities"
  showHome: ->
    rank = app.Auth.get("rank")
    switch rank
      when "root"
        app.regions.getRegion('main').show(new RootHomeView())
      when "redacteur"
        app.regions.getRegion('main').show(new RedacteurHomeView())
      when "joueur"
        app.regions.getRegion('main').show(new JoueurHomeView())
      else
        app.regions.getRegion('main').show(new OffHomeView())

  showNotFound: ->
    view = new AlertView {
      message: "Page introuvable"
      dismiss: false
    }
    app.regions.getRegion('main').show(view)
}

export controller = new Controller()
