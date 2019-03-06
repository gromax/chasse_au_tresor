ArianeItem = Backbone.Model.extend {}

ArianeCollection = Backbone.Collection.extend {
	model:ArianeItem
}

home = {
	text: "<i class='fa fa-home'></i>"
	link: "home"
	e: "home:show"
	active: false
}

export ArianeController = {
	collection: new ArianeCollection([ home ]) # comme on ne parse pas ici, le active restera false

	reset: (models)->
		models.unshift(home)
		_.each models, (item)-> item.active = true
		_.last(models).active = false
		@collection.reset(models)

	add: (model)->
		_.last(@collection.models).set("active",true)
		if _.isArray(model)
			_.each model, (item)-> item.active = true
			_.last(model).active = false
		else
			model.active = false
		@collection.add(model)
}
