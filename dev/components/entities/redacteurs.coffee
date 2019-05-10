Item = Backbone.Model.extend {
	urlRoot: "api/redacteurs"

	defaults: {
		nom: ""
		username: ""
	},

	parse: (data) ->
		if (data.id)
			data.id = Number(data.id)
		if (data.count_evenements)
			data.count_evenements = Number(data.count_evenements)
		else
			data.count_evenements = 0
		return data

	toJSON: ->
		return _.pick(this.attributes, 'id', 'nom', 'username', 'pwd');

	validate: (attrs, options) ->
		errors = {}
		if not attrs.nom
			errors.nom = "Ne doit pas être vide"
		else
			if attrs.nom.length<2
				errors.nom = "Trop court"

		if not attrs.username
			errors.nom = "L'identifiant ne doit pas être vide"

		if not _.isEmpty(errors)
			return errors

}

Collection = Backbone.Collection.extend {
	url: "api/redacteurs"
	model: Item
	comparator: "nom"
}

export {
	Collection
	Item
}
