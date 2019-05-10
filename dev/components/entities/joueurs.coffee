Item = Backbone.Model.extend {
	urlRoot: "api/joueurs"

	defaults: {
		nom: ""
		username: ""
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
		return _.pick(this.attributes, 'id', 'nom', 'username', 'pwd');

	validate: (attrs, options) ->
		errors = {}
		if (not attrs.nom) or (attrs.nom.length<4)
			errors.nom = true

		if (not attrs.username) or (attrs.username.length<4)
			errors.username = true

		if (not attrs.pwd) or (attrs.pwd.length<4)
			errors.pwd = true

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
