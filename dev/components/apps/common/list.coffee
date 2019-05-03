import { View } from 'backbone.marionette'
import template from 'templates/common/list-layout.tpl'
import templatePanel from 'templates/common/list-panel.tpl'

Panel = View.extend {
  template: templatePanel

  triggers: {
    "click button.js-new": "item:new"
  }

  events: {
    "submit #filter-form": "applyFilter"
  }

  ui: {
    criterion: "input.js-filter-criterion"
  },

  templateContext: ->
    {
      filterCriterion: @options.filterCriterion or ""
      showAddButton: @options.showAddButton is true
      title: @options.title or ""
    }

  applyFilter: (e)->
    e.preventDefault();
    criterion = @ui.criterion.val()
    @trigger("items:filter", criterion);

  onSetFilterCriterion: (criterion)->
    @ui.criterion.val(criterion)
}

Layout = View.extend {
  template: template
  regions: {
    panelRegion: "#panel-region"
    itemsRegion: "#items-region"
  }
}

export { Layout, Panel }
