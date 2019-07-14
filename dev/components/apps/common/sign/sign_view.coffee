import { View } from "backbone.marionette"
import { SubmitClicked } from 'apps/common/behaviors.coffee'
import signin_tpl from "templates/common/sign/sign.tpl"
import { app } from 'app'

SignView = View.extend {
  className:"card"
  signin: true
  showForgotten: false
  username: ""
  pwd: ""
  showToggleButton: false
  behaviors: [SubmitClicked]
  template: signin_tpl

  events: {
    "click button.js-submit": "submitClicked"
    "click a.js-toggle": "toggleInUp"
    "click button.js-forgotten": "forgottenClicked"
  }

  toggleInUp: (e)->
    e.preventDefault()
    @options.signin = not @options.signin
    @render()

  forgottenClicked: (e)->
    e.preventDefault()
    email = $("input[name='username']",@$el).val()
    adm = $("input[name='adm']",@$el).val() is "1"
    emailRegex = /^[a-zA-Z0-9_-]+(.[a-zA-Z0-9_-]+)*@[a-zA-Z0-9._-]{2,}\.[a-z]{2,4}$/
    if emailRegex.test(email)
      @trigger("forgottenButton:click", email, adm)
    else
      @onFormDataInvalid [{ success:false, message:"L'adresse e-mail n'est pas valide !" }]

  templateContext: ->
    {
      showForgotten: @getOption "showForgotten"
      signin: @getOption "signin"
      username: @getOption "username"
      pwd: @getOption "pwd"
      showToggleButton: @getOption "showToggleButton"
    }
}

export { SignView }
