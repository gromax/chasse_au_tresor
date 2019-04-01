Item = Backbone.Model.extend {
	urlRoot: "api/evenements"

	defaults: {
		titre: ""
		idProprietaire: false
		description: ""
		actif: false
	},

	parse: (data) ->
		if (data.id)
			data.id = Number(data.id)
		if (data.idProprietaire)
			data.idProprietaire = Number(data.idProprietaire)
		data.actif = (data.actif is "1") or (data.actif is 1) or (data.actif is true)
		if (data.count_parties)
			data.count_parties = Number(data.count_parties)
		else
			data.count_parties = 0
		if (data.count_items)
			data.count_items = Number(data.count_items)
		else
			data.count_items = 0
		return data

	toJSON: ->
		return _.pick(this.attributes, 'id', 'idProprietaire', 'titre', 'description', 'actif');

	validate: (attrs, options) ->
		errors = {}
		if not attrs.titre
			errors.titre = "Ne doit pas être vide"
		if not _.isEmpty(errors)
			return errors
}

Collection = Backbone.Collection.extend {
	url: "api/evenements"
	model: Item
	comparator: "titre"
}

export {
	Item
	Collection
}
