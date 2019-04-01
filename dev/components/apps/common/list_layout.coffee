import Marionette from 'backbone.marionette'
import template from 'templates/common/list-layout.tpl'

export default Marionette.View.extend {
	template: template
	regions: {
		panelRegion: "#panel-region"
		itemsRegion: "#items-region"
	}
}
