import { View } from "backbone.marionette"
import Syphon from "backbone.syphon"
import template from "templates/common/sign/sign.tpl"

app = require("app").app

SignView = View.extend {
	className:"card"
	template: template

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

	submitClicked: (e)->
		e.preventDefault()
		data = Syphon.serialize(@)
		if @options.signin is true
			data.adm = (data.adm is "1")
			@trigger("form:submit", data)
		else
			error = false
			$form = @$el.find("form")
			_.each ["nom", "username", "pwd"], (k)->
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

	forgottenClicked: (e)->
		e.preventDefault()
		email = $("input[name='username']",@$el).val()
		adm = $("input[name='adm']",@$el).val() is "1"
		emailRegex = /^[a-zA-Z0-9_-]+(.[a-zA-Z0-9_-]+)*@[a-zA-Z0-9._-]{2,}\.[a-z]{2,4}$/
		if emailRegex.test(email)
			@trigger("forgottenButton:click", email, adm)
		else
			@onFormDataInvalid [{ success:false, message:"L'adresse e-mail n'est pas valide !" }]

	onFormDataInvalid: (errors)->
		$("input",@$el).each ()->
			$(@).removeClass("is-invalid")
		$view = @$el
		if @options.signin is true
			clearFormErrors = () ->
				$("div.alert", $view).each( ()->
					$(@).remove()
				)

			$container = $view.find("#messages")
			markErrors = (value)->
				$errorEl
				if value.success
					$errorEl = $("<div>", { class: "alert alert-success", role:"alert", text: value.message })
				else
					$errorEl = $("<div>", { class: "alert alert-danger", role:"alert", text: value.message })
				$container.append($errorEl)

			clearFormErrors()
			_.each(errors, markErrors)
		else
			_.each errors, (v,k)->
				$view.find("#user-#{k}").addClass("is-invalid")

	templateContext: ->
		{
			adm: @options.adm ? 0
			showForgotten: @options.showForgotten is true
			signin: @options.signin is true
			desactiveModeChoiceButton: @options.desactiveModeChoiceButton is true
			username: @options.username ? ""
			pwd: @options.pwd ? ""
			showToggleButton: @options.showToggleButton is true
		}
}

export { SignView }
