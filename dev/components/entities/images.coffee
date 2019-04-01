Item = Backbone.Model.extend {
	urlRoot: "api/images"

	defaults: {
		idEvenement: false
		hash: ""
	},

	parse: (data) ->
		if (data.id)
			data.id = Number(data.id)
		if (data.idEvenement)
			data.idEvenement = Number(data.idEvenement)
		return data

}

Collection = Backbone.Collection.extend {
	url: "api/images"
	model: Item
}

export {
	Item
	Collection
}
