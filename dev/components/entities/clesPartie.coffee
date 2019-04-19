Item = Backbone.Model.extend {
	urlRoot: "api/clesPartie"

	defaults: {
		idPartie: false
		succes: false
		essai:""
	},

	toJSON: ->
		out = _.pick(this.attributes, 'id', 'idPartie', 'essai', 'date', 'data')
		out['data'] = JSON.stringify(out['data'])
		return out

	parse: (data) ->
		if (data.id)
			data.id = Number(data.id)
		if (data.idPartie)
			data.idPartie = Number(data.idPartie)
		data.succes = (data.succes is "1") or (data.succes is 1) or (data.succes is true)
		if data.data then data.data = JSON.parse(data.data)
		else data.data = {}
		return data

	validate: (attrs, options) ->
		errors = {}
		if not attrs.essai
			errors.essai = "Ne doit pas être vide"
		if not _.isEmpty(errors)
			return errors

}

Collection = Backbone.Collection.extend {
	url: "api/clesPartie"
	model: Item
	comparator: "date"
}

export {
	Item
	Collection
}