import Marionette from 'backbone.marionette'
import template from 'templates/evenements/list/panel.tpl'

export default Marionette.View.extend {
	template: template

	triggers: {
		"click button.js-new": "item:new"
	}

	events: {
		"submit #filter-form": "applyFilter"
	}

	ui: {
		criterion: "input.js-filter-criterion"
	},

	serializeData: ()->
		{
			filterCriterion: @options.filterCriterion or ""
			showAddButton: @options.showAddButton is true
		}

	applyFilter: (e)->
		e.preventDefault();
		criterion = @ui.criterion.val()
		@trigger("items:filter", criterion);

	onSetFilterCriterion: (criterion)->
		@ui.criterion.val(criterion)
}

