import FormView from 'apps/common/item_form_view.coffee'
import template from 'templates/redacteurs/common/form.tpl'

export default FormView.extend {
	template: template

	serializeData: () ->
		data = _.clone(@model.attributes)
		data.showPWD = @options.showPWD or false
		data.showInfos = @options.showInfos or false
		return data

}
