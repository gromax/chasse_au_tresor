import Marionette from 'backbone.marionette'
import Syphon from 'backbone.syphon'

export default Marionette.View.extend {
	itemMarkup:"item"
	events: {
		"click button.js-submit": "submitClicked"
	}

	initialize: ->
		@title = @options.title or @title or ""

	submitClicked: (e)->
		e.preventDefault()
		data = Syphon.serialize(@)
		@trigger("form:submit", data)

	onRender: ->
		if @options.generateTitle
			$title = $("<h1>", { text: @title })
			@$el.prepend($title)

	onFormDataInvalid: (errors)->
		$view = @$el
		clearFormErrors = ()->
			$form = $view.find("form")
			$form.find(".help-inline.text-danger").each( ()->
				$(this).remove()
			)
			$form.find(".form-group.has-error").each( ()->
				$(this).removeClass("has-error")
			)

		itemMarkup = @itemMarkup
		markErrors = (value, key) ->
			$controlGroup = $view.find("##{itemMarkup}-#{key}").closest(".form-group")
			$controlGroup.addClass("has-error")
			if $.isArray(value)
				value.forEach( (el)->
					$errorEl = $("<span>", { class: "help-inline text-danger", text: el })
					$controlGroup.append($errorEl)
				)
			else
				$errorEl = $("<span>", { class: "help-inline text-danger", text: value })
				$controlGroup.append($errorEl)

		clearFormErrors()
		_.each(errors, markErrors)

}
