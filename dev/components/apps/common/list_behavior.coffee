import { Behavior } from 'backbone.marionette'

SortList = Behavior.extend {
	events: {
		"click a.js-sort":"sortFct"
	}

	sortFct: (e)->
		e.preventDefault()
		tag = $(e.currentTarget).attr("sort")
		if @collection.comparatorAttr is tag
			@collection.comparatorAttr = "inv_"+tag
			@collection.comparator = (a,b)->
				if a.get(tag)>b.get(tag)
					-1
				else
					1
		else
			@collection.comparatorAttr = tag
			@collection.comparator = tag
		@collection.sort()

}


export { SortList }
