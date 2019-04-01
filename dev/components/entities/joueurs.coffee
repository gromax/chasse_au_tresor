Item = Backbone.Model.extend {
	urlRoot: "api/joueurs"

	defaults: {
		nom: ""
		email: ""
	},

	parse: (data) ->
		if (data.id)
			data.id = Number(data.id)
		if (data.count_parties)
			data.count_parties = Number(data.count_parties)
		else
			data.count_parties = 0
		return data

	toJSON: ->
		return _.pick(this.attributes, 'id', 'nom', 'email', 'pwd');

	validate: (attrs, options) ->
		errors = {}
		if not attrs.nom
			errors.nom = "Ne doit pas être vide"
		else
			if attrs.nom.length<2
				errors.nom = "Trop court"
		# en présence d'un cas, peut importe l'email
		reCas =  /^[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+$/

		if not attrs.email
			errors.nom = "L'identifiant ne doit pas être vide"

		if not _.isEmpty(errors)
			return errors
}

Collection = Backbone.Collection.extend {
	url: "api/joueurs"
	model: Item
	comparator: "nom"
}

export {
	Item
	Collection
}
