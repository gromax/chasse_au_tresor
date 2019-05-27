import Marionette from 'backbone.marionette'
import templateList from 'templates/joueurs/list/list.tpl'
import templateItem from 'templates/joueurs/list/item.tpl'
import templateNone from 'templates/joueurs/list/none.tpl'
import { SortList, FilterList } from 'apps/common/list_behavior.coffee'

app = require('app').app

noView = Marionette.View.extend {
	template:  templateNone
	tagName: "tr"
	className: "alert"
}

ItemView = Marionette.View.extend {
	tagName: "tr"
	template: templateItem
	triggers: {
		"click td a.js-edit": "edit"
		"click td a.js-editPwd": "editPwd"
		"click button.js-delete": "delete"
	}

	flash: (cssClass)->
		$view = @$el
		$view.hide().toggleClass("table-"+cssClass).fadeIn(800, ()->
			setTimeout( ()->
				$view.toggleClass("table-"+cssClass)
			, 500)
		)

	remove: ()->
		self = @
		@$el.fadeOut( ()->
			#self.model.destroy()
			self.trigger("model:destroy", @model)
			Marionette.View.prototype.remove.call(self)
		)
}

export default Marionette.CollectionView.extend {
	tagName: "table"
	className: "table table-hover"
	template: templateList
	childViewContainer: "tbody"
	childView: ItemView
	childViewEventPrefix: "item"
	emptyView: noView
	behaviors: [SortList, FilterList]
	filterKeys: ["nom", "username"]

}
