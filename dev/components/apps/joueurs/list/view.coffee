import Marionette from 'backbone.marionette'
import templateList from 'templates/joueurs/list/list.tpl'
import templateItem from 'templates/joueurs/list/item.tpl'
import templateNone from 'templates/joueurs/list/none.tpl'
import { SortList, FilterList, DestroyWarn } from 'apps/common/behaviors.coffee'

app = require('app').app

noView = Marionette.View.extend {
	template:  templateNone
	tagName: "tr"
	className: "alert"
}

ItemView = Marionette.View.extend {
	tagName: "tr"
	template: templateItem
	behaviors: [DestroyWarn]
	triggers: {
		"click td a.js-edit": "edit"
		"click td a.js-editPwd": "editPwd"
	}

	flash: (cssClass)->
		$view = @$el
		$view.hide().toggleClass("table-"+cssClass).fadeIn(800, ()->
			setTimeout( ()->
				$view.toggleClass("table-"+cssClass)
			, 500)
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
