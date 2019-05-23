Item = Backbone.Model.extend {
	urlRoot: "api/parties"

	defaults: {
		idEvenement: false
		idProprietaire: false
		nomProprietaire: ""
		titreEvenement: ""
		descriptionEvenement: ""
		dateDebut_fr: ""
		duree: "-"
		score:0
	},

	parse: (data) ->
		if (data.id)
			data.id = Number(data.id)
		if (data.idProprietaire)
			data.idProprietaire = Number(data.idProprietaire)
		if (data.idEvenement)
			data.idEvenement = Number(data.idEvenement)
		if (data.score)
			data.score = Number(data.score)
		if (data.dateDebut)
			data.dateDebutTime = Date.parse(data.dateDebut)
			data.dateDebut_fr = data.dateDebut.replace(/([0-9]{4})-([0-9]{2})-([0-9]{2})\s*([0-9]{2}:[0-9]{2}:[0-9]{2})/,"$3/$2/$1 $4")
		data.actif = (data.actif is "1") or (data.actif is 1) or (data.actif is true)

		if (data.dateFin)
			data.dateFinTime = Date.parse(data.dateFin)
			data.dateFin_fr = data.dateFin.replace(/([0-9]{4})-([0-9]{2})-([0-9]{2})\s*([0-9]{2}:[0-9]{2}:[0-9]{2})/,"$3/$2/$1 $4")

		if data.dateDebut and data.dateFin
			duree = Math.round((data.dateFinTime - data.dateDebutTime)/60000)
			duree_min = duree % 60
			dureeStr = "#{duree_min}min"
			if duree>60
				duree_h = ((duree - duree_min)/60) % 24
				dureeStr = "#{duree_h}h "+dureeStr
			if duree>1440
				duree_j = (duree - duree % 1440 )/1440
				dureeStr = "#{duree_j}j "+dureeStr
			data.dureeStr = dureeStr
			data.duree = duree
		else
			data.dureeStr = ""
			data.duree = Number.POSITIVE_INFINITY
		return data

	toJSON: ->
		return _.pick(this.attributes, 'id', 'fini', 'idEvenement');

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
