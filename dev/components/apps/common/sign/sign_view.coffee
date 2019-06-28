import { View } from "backbone.marionette"
import { SubmitClicked } from 'apps/common/behaviors.coffee'
import signin_tpl from "templates/common/sign/sign.tpl"
import { app } from 'app'

SignView = View.extend {
  className:"card"
  signin: true
  showForgotten: false
  desactiveModeChoiceButton: false
  username: ""
  pwd: ""
  showToggleButton: false
  behaviors: [SubmitClicked]
  template: signin_tpl

  events: {
    "click button.js-submit": "submitClicked"
    "click a.js-toggle": "toggleInUp"
    "click button.js-unsetAdm": "unsetAdm"
    "click button.js-setAdm": "setAdm"
    "click button.js-forgotten": "forgottenClicked"
  }

  setAdm: (e) ->
    e.preventDefault()
    $('button.js-unsetAdm').removeClass('btn-success').addClass('btn-outline-success')
    $('button.js-setAdm').removeClass('btn-outline-success').addClass('btn-success')
    $("input[name='adm']").val("1")
    $(".card-header",@$el).html("Connexion &nbsp; <span class='badge badge-warning'>mode rédacteur</span>")

  unsetAdm: (e) ->
    e.preventDefault()
    $('button.js-setAdm').removeClass('btn-success').addClass('btn-outline-success')
    $('button.js-unsetAdm').removeClass('btn-outline-success').addClass('btn-success')
    $("input[name='adm']").val("0")
    $(".card-header",@$el).html("Connexion")

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
      adm: @options.adm ? 0
      showForgotten: @getOption "showForgotten"
      signin: @getOption "signin"
      desactiveModeChoiceButton: @getOption "desactiveModeChoiceButton"
      username: @getOption "username"
      pwd: @getOption "pwd"
      showToggleButton: @getOption "showToggleButton"
    }
}

export { SignView }
