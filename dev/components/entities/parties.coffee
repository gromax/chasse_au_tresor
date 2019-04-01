Item = Backbone.Model.extend {
	urlRoot: "api/parties"

	defaults: {
		titre: ""
		idEvenement: false
		idProprietaire: false
		fini: false
		nomProprietaire: ""
		fini: false
		titreEvenement: ""
		dateDebut_fr: ""
		duree: "-"
	},

	parse: (data) ->
		if (data.id)
			data.id = Number(data.id)
		if (data.idProprietaire)
			data.idProprietaire = Number(data.idProprietaire)
		if (data.idEvenement)
			data.idEvenement = Number(data.idEvenement)
		if (data.dateDebut)
			data.dateDebut_fr = data.dateDebut
		data.fini = (data.fini is "1") or (data.fini is 1) or (data.fini is true)
		return data
}

Collection = Backbone.Collection.extend {
	url: "api/parties"
	model: Item
	comparator: "dateDebut"
}

export {
	Item
	Collection
}
