import { View } from 'backbone.marionette'
import new_partie_tpl from 'templates/parties/new/new_partie.tpl'

NewPartieView = View.extend {
  tagName: "div"
  className: "jumbotron"
  template: new_partie_tpl

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

export { NewPartieView }
