app = require('app').app

API = {
	showAriane: ->
		require("apps/ariane/show/show_controller.coffee").controller.showAriane()
}

app.on "ariane:show", (data) ->
	API.showAriane()
