import { View } from 'backbone.marionette'
import template from 'templates/home/show/joueur.tpl'

app = require('app').app

export default View.extend {
  template: template
  triggers: {
    "click a.js-edit-me": "edit:me"
    "click a.js-evenements": "evenements:list"
    "click a.js-parties": "parties:list"
  },

  onEditMe: (e) ->
    app.trigger "edit:me"

  onEvenementsList: (e) ->
    app.trigger "evenements:list"

  onPartiesList: (e) ->
    app.trigger "parties:list"

}
