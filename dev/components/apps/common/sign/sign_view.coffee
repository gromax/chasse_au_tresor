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
	}

	toggleInUp: (e)->
		e.preventDefault()
		@options.signin = not @options.signin
		@render()

	submitClicked: (e)->
		e.preventDefault()

		data = Syphon.serialize(@)
		if @options.signin is true
			data.adm = (@options.showRedacCheck is true) and ($("#admCheck").prop('checked'))
			@trigger("form:submit", data)
		else
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
			showForgotten: @options.showForgotten is true
			signin: @options.signin is true
			showRedacCheck: @options.showRedacCheck is true
			email: @options.email ? ""
			pwd: @options.pwd ? ""
			showToggleButton: @options.showToggleButton is true
		}
}

export { SignView }
