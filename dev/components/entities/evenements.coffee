Item = Backbone.Model.extend {
	urlRoot: "api/evenements"

	defaults: {
		titre: ""
		idProprietaire: false
		description: ""
		actif: false
		hash: ""
	},

	parse: (data) ->
		if (data.id)
			data.id = Number(data.id)
		if (data.idProprietaire)
			data.idProprietaire = Number(data.idProprietaire)
		data.actif = (data.actif is "1") or (data.actif is 1) or (data.actif is true)
		data.visible = (data.visible is "1") or (data.visible is 1) or (data.visible is true)
		if (data.count_parties)
			data.count_parties = Number(data.count_parties)
		else
			data.count_parties = 0
		if (data.count_items)
			data.count_items = Number(data.count_items)
		else
			data.count_items = 0
		if typeof data.idPartie isnt 'undefined'
			if data.idPartie isnt null
				data.idPartie = Number data.idPartie
			else
				data.idPartie = false
			data.fini = (data.fini is "1") or (data.fini is 1) or (data.fini is true)
		return data

	toJSON: ->
		return _.pick(this.attributes, 'id', 'idProprietaire', 'titre', 'description', 'actif', 'visible');

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
