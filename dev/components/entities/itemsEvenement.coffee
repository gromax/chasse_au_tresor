SubItem = Backbone.Model.extend {
	defaults: {
		type: "brut"
		editMode: false
		index: 0
	}

	parse: (data)->
		switch data.type
			when "brut"
				unless data.contenu? then data.contenu=""
			when "url-image"
				unless data.imgUrl? then data.imgUrl=""
			when "upload-image"
				unless data.imgName? then data.imgName=""
		return data
	toJSON: ->
		return _.omit(@attributes, "editMode")
}

SubCollection = Backbone.Collection.extend {
	model: SubItem
	comparator: "index"
}

Item = Backbone.Model.extend {
	urlRoot: "api/itemsEvenement"

	defaults: {
		idEvenement: false
		type: 0
		data:""
		cle:""
	},

	toJSON: ->
		@set("data", JSON.stringify(@get("subCollection").toJSON()))
		return _.pick(this.attributes, 'id', 'idEvenement', 'type', 'data', 'cle');

	parse: (data) ->
		if (data.id)
			data.id = Number(data.id)
		if (data.idEvenement)
			data.idEvenement = Number(data.idEvenement)
		if (data.type)
			data.type = Number(data.type)
		data.subCollection = new SubCollection()
		try
			d = JSON.parse(data.data)
			if not _.isArray(d) then d = []
		catch e
			d = []
		finally
			data.subCollection.add d, { parse:true }
		return data

	validate: (attrs, options) ->
		errors = {}
		if not attrs.cle
			errors.cle = "Ne doit pas être vide"
		if not _.isEmpty(errors)
			return errors

}

Collection = Backbone.Collection.extend {
	url: "api/itemsEvenement"
	model: Item
}

export {
	Item
	Collection
}