SubItem = Backbone.Model.extend {
	defaults: {
		type: "brut"
		index: 0
	}

	parse: (data)->
		switch data.type
			when "brut"
				unless data.contenu? then data.contenu=""
			when "image"
				unless data.imgUrl? then data.imgUrl=""
				unless data.width? then data.width="100%"
			when "pdf"
				unless data.url? then data.url=""
		return data

	validate: (attrs) ->
		errors = {}
		if _.has(attrs,"width")
			regexWidth = /^[1-9][0-9]*(px|%)$/
			if regexWidth.test(attrs.width) is false
				errors.width = "La largeur doit être de forme 50px ou 50%"
		if not _.isEmpty(errors)
			return errors
}

SubItemCollection = Backbone.Collection.extend {
	model: SubItem
	comparator: "index"
}

Item = Backbone.Model.extend {
	urlRoot: "api/itemsEvenement"

	defaults: {
		idEvenement: false
		type: 0
		subItemsData:"[]"
		tagCle:"étiquette"
		regexCle:"^cle$"
		pts: 0
	},

	parse: (data) ->
		if (data.id)
			data.id = Number(data.id)
		if (data.idEvenement)
			data.idEvenement = Number(data.idEvenement)
		if (data.type)
			data.type = Number(data.type)
		if (data.pts)
			data.pts = Number(data.pts)
		return data

	validate: (attrs, options) ->
		errors = {}
		if not attrs.tagCle
			errors.tagCle = "Ne doit pas être vide"
		if not attrs.regexCle
			errors.regexCle = "Ne doit pas être vide"
		if attrs.pts and (/^\s*[-+]?\s*[0-9]+$/.test(attrs.pts) is false)
				errors.pts = "Entier positif ou négatif"
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
	SubItemCollection
}
