require('app').app.on "header:show", () ->
	require("apps/header/show/controller.coffee").controller.show()
