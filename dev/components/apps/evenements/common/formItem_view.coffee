import FormView from 'apps/common/item_form_view.coffee'
import template from 'templates/evenements/common/formItem.tpl'

export default FormView.extend {
	template: template

	ui: {
		test: 'input.js-test'
		cle: '#item-cle'
	}

	triggers: {
		"input @ui.test": "test:reload"
		"input @ui.cle": "test:reload"
	}

	onTestReload: ->
		test = @ui.test.val()
		test = test.normalize('NFD').replace(/[\u0300-\u036f]/g, "")
		cle = @ui.cle.val()
		result = false
		if test!="" and cle !=""
			try
				r = new RegExp(cle, 'gi')
				result = r.test(test)
			catch e
				result = false
			finally
				if result
					@ui.test.addClass("is-valid")
					@ui.test.removeClass("is-invalid")
				else
					@ui.test.addClass("is-invalid")
					@ui.test.removeClass("is-valid")
		else
			@ui.test.removeClass("is-valid is-invalid")

}
