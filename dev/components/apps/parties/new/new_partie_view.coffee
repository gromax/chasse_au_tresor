import Marionette from 'backbone.marionette'
import template from 'templates/parties/new/new_partie.tpl'

app = require('app').app

export default Marionette.View.extend {
  tagName: "div"
  className: "jumbotron"
  template: template

  events: {
    "click a.js-continue": "continueClicked"
    "click button.js-start": "startClicked"
  }

  continueClicked: (e)->
    e.preventDefault()
    @trigger("partie:continue", @model.get("idPartie"))

  startClicked: (e)->
    e.preventDefault()
    @trigger("partie:start", @model.get("id"))


  templateContext:->
    l = @model.get("idPartie")
    return { hasPartie: typeof l is "number" }
}
