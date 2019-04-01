import Marionette from 'backbone.marionette'
import template from 'templates/common/workInProgress.tpl';

app = require('app').app
export default Marionette.Application.extend {
	template: template
}
