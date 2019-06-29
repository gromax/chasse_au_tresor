import { View } from 'backbone.marionette'
import user_edit_tpl from 'templates/common/user-edit.tpl'
import { SubmitClicked, EditItem } from 'apps/common/behaviors.coffee'

EditUserView = View.extend {
  template: user_edit_tpl
  behaviors: [SubmitClicked, EditItem]
  showPWD: false
  showInfos: true
  showToggle: false
  generateTitle: false
  triggers: {
    "click a.js-toggle" : "toggle"
  }
  initialize: ->
    @title = @getOption "title"
  onRender: ->
    if @getOption "generateTitle"
      $title = $("<h1>", { text: @title })
      @$el.prepend($title)
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
      showPWD: @getOption "showPWD"
      showInfos: @getOption "showInfos"
      showToggle: @getOption "showToggle"
    }
}

NewUserView = View.extend {
  template: user_edit_tpl
  behaviors: [SubmitClicked, EditItem]
  initialize: ->
    @title = @getOption "title"
  templateContext: ->
    {
      showPWD: true
      showInfos: true
      showToggle: false
    }
}


export { EditUserView, NewUserView }
