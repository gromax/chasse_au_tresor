import { Behavior } from 'backbone.marionette'

SortList = Behavior.extend {
	events: {
		"click a.js-sort":"sortFct"
	}

	sortFct: (e)->
		e.preventDefault()
		tag = $(e.currentTarget).attr("sort")
		collection = @view.collection
		if collection.comparatorAttr is tag
			collection.comparatorAttr = "inv_"+tag
			collection.comparator = (a,b)->
				if a.get(tag)>b.get(tag)
					-1
				else
					1
		else
			collection.comparatorAttr = tag
			collection.comparator = tag
		collection.sort()
}

FilterList = Behavior.extend {
	initialize: ->
		if (typeof @view.options.filterCriterion isnt "undefined") and (@view.options.filterCriterion isnt "")
			@view.trigger("set:filter:criterion",@view.options.filterCriterion, { preventRender: true })
	onSetFilterCriterion: (criterion, options)->
		criterion = criterion.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toLowerCase()
		if criterion is "" or typeof @view.filterKeys is "undefined"
			@view.removeFilter(filterFct, options)
		else
			filterKeys = @view.filterKeys
			parseFct = (model) ->
				reductionFct = (m,k) ->
					m+model.get(k)
				_.reduce(filterKeys, reductionFct, "").normalize('NFD').replace(/[\u0300-\u036f]/g, "").toLowerCase()
			filterFct = (view, index, children) ->
				parseFct(view.model).indexOf(criterion) isnt -1
			@view.setFilter(filterFct, options)

}


export { SortList, FilterList }
