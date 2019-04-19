import Marionette from "backbone.marionette"
import Syphon from "backbone.syphon"
import template from "templates/home/signup/signup.tpl"

app = require("app").app

export default Marionette.View.extend {
  className:"card"
  template: template

  events: {
    "click button.js-submit": "submitClicked"
  }

  submitClicked: (e)->
    e.preventDefault()
    data = Syphon.serialize(@)
    error = false
    $form = @$el.find("form")
    _.each ["nom", "email", "pwd"], (k)->
        $form.find("#user-#{k}").removeClass("is-invalid").removeClass("is-valid")

    $inp = $form.find("#user-pwd-2")
    if $inp.val() != data.pwd
      $inp.addClass("is-invalid")
      error = true
    else
      $inp.removeClass("is-invalid")
    $robot = $form.find("#nrCheck")
    if not $robot.prop('checked')
      $robot.addClass("is-invalid")
      error = true
    else
      $robot.removeClass("is-invalid")

    if not error
      @trigger("form:submit", data)


  onFormDataInvalid: (errors)->
    $view = @$el
    _.each ["nom", "email", "pwd"], (k)->
      $it = $view.find("#user-#{k}")
      if errors[k]
        $it.addClass("is-invalid")
      else
        $it.addClass("is-valid")
}
