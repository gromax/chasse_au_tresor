import Marionette from "backbone.marionette"
import Syphon from "backbone.syphon"
import template from "templates/home/login/login.tpl"

app = require("app").app

export default Marionette.View.extend {
	className:"card"
	template: template

	events: {
		"click button.js-submit": "submitClicked"
	}

	initialize: ->
		@title = @options.title ? "Connexion";

	onRender: ->
		if @options.generateTitle
			$title = $("<div>", { text: "Connexion", class:"card-header"})
			@$el.prepend($title)

	submitClicked: (e)->
		e.preventDefault()
		data = Syphon.serialize(@)
		data.adm = $("#admCheck").prop('checked')
		@trigger("form:submit", data)


	onFormDataInvalid: (errors)->
		$view = @$el
		clearFormErrors = () ->
			$form = $view.find("form")
			$form.find("div.alert").each( ()->
				$(this).remove()
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

	templateContext: ->
		{ showForgotten: @options.showForgotten }
}
