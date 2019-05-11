import FormView from 'apps/common/item_form_view.coffee'
import template from 'templates/common/form-user.tpl'

export default FormView.extend {
  template: template

  triggers: {
    "click a.js-toggle" : "toggle"
  }

  onToggle: ->
    if @options.showPWD is true
      @options.showPWD = false
      @options.showInfos = true
    else
      @options.showPWD = true
      @options.showInfos = false
    @render()

  templateContext: ->
    {
      showPWD: @options.showPWD is true
      showInfos: @options.showInfos is true
      showToggle: @options.showToggle is true
    }

}
