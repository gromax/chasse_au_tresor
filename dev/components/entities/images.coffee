Item = Backbone.Model.extend {
	urlRoot: "api/images"

	defaults: {
		idEvenement: false
		hash: ""
		ext: ""
	},

	saveImg: (formData) ->
		formData.append("idEvenement", @get("idEvenement"))
		defer = $.Deferred()
		request = $.ajax({
			method: 'POST'
			url: 'api/images'
			dataType: 'json'
			data: formData
			processData: false
			contentType: false
		})

		that = @
		request.done( (data)->
			that.set(data)
			defer.resolve(that)
		).fail( (response)->
			defer.reject(response)
		)
		return defer.promise()


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
