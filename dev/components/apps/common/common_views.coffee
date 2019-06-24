import { View } from 'backbone.marionette'
import { FilterPanel } from 'apps/common/behaviors.coffee'
import missing_tpl from "templates/common/missing.tpl"
import alert_tpl from 'templates/common/alert.tpl'
import list_layout_tpl from 'templates/common/list-layout.tpl'
import list_panel_tpl from 'templates/common/list-panel.tpl'
import work_in_progress_tpl from 'templates/common/workInProgress.tpl';

WorkInProgressView = View.extend {
  template: work_in_progress_tpl
}

ListPanel = View.extend {
  filterCriterion: ""
  showAddButton: false
  title: ""
  template: list_panel_tpl
  behaviors: [FilterPanel]
  triggers: {
    "click button.js-new": "item:new"
  }
  templateContext: ->
    {
      title: @getOption "title"
      showAddButton: @getOption "showAddButton"
      filterCriterion: @getOption "filterCriterion"
    }
}

ListLayout = View.extend {
  template: list_layout_tpl
  regions: {
    panelRegion: "#panel-region"
    itemsRegion: "#items-region"
  }
}

MissingView = View.extend {
  message: "Cet item n'existe pas"
  templateContext: ->
    {
      message: @getOption "message"
    }

  template: missing_tpl
}

AlertView = View.extend {
  template: alert_tpl
  dismiss: true
  className: -> "alert alert-"+(@options.type or "danger")

  initialize: (options) ->
    options = options ? {};
    @title = options.title ? "Erreur !"
    @message = options.message ? "Erreur inconnue. Reessayez !"
    @type = options.type ? "danger"

  templateContext: ->
    {
      title: @title
      message: @message
      dismiss: @getOption "dismiss"
      type: @type
    }

}

export { MissingView, AlertView, ListPanel, ListLayout, WorkInProgressView }