import FormView from 'apps/common/item_form_view.coffee'
import template from 'templates/evenements/common/formItem.tpl'

app = require('app').app

export default FormView.extend {
	template: template

	ui: {
		test: 'input.js-test'
		regexCle: '#item-regexCle'
	}

	# attention events est déjà défini dans FormView

	triggers: {
		"input @ui.test": "test:reload"
		"input @ui.regexCle": "test:reload"
		"click button.js-gps": "set:gps"
	}

	onSetGps: ->
		options = {
			enableHighAccuracy: true
			timeout: 5000
			maximumAge: 0
		}
		self = @
		errorFct = (err) ->
			app.trigger("header:loading", false)
			console.warn("ERREUR (#{err.code}): #{err.message}")

		successFct = (pos) ->
			app.trigger("header:loading", false)
			crd = pos.coords;
			self.ui.regexCle.val("gps=#{crd.latitude},#{crd.longitude}")
		app.trigger("header:loading", true)
		navigator.geolocation.getCurrentPosition(successFct, errorFct, options)

	onTestReload: ->
		test = @ui.test.val()
		test = test.normalize('NFD').replace(/[\u0300-\u036f]/g, "")
		regexCle = @ui.regexCle.val()
		result = false
		if test!="" and regexCle !=""
			try
				# On test si la clé est de type gps
				gpsRegex = /^gps=[0-9]+\.[0-9]+,[0-9]+\.[0-9]+$/
				if gpsRegex.test(regexCle)
					# C'est du gps
					# On commence par tester si le test l'est également
					if gpsRegex.test(test)
						# le test est bien du gps
						# il faut faire le calcul
						# d'abord pour la clé
						a1 = regexCle.split "="
						strCoords = a1[1].split(",")
						coordsCle = {
							y: Number strCoords[0]
							x: Number strCoords[1]
						}
						# même chose pour le test
						a1 = test.split "="
						strCoords = a1[1].split(",")
						coordsTest = {
							y: Number strCoords[0]
							x: Number strCoords[1]
						}
						# ensuite calcul
						dx = 60*(coordsTest.x - coordsCle.x)*Math.cos((coordsCle.y+coordsTest.y)/2*0.01745329251994329577)
						dy = 60*(coordsTest.y - coordsCle.y)
						dist = Math.sqrt(dx*dx + dy*dy)*1852 # exprimé en minutes d'arc^2
						result = (dist <= GPS_LIMIT)
					else
						# le test n'est pas du gps
						result = false
				else
					# Ce n'est pas du gps
					r = new RegExp(regexCle, 'gi')
					result = r.test(test)
			catch e
				result = false
			finally
				if result
					@ui.test.addClass("is-valid")
					@ui.test.removeClass("is-invalid")
				else
					@ui.test.addClass("is-invalid")
					@ui.test.removeClass("is-valid")
		else
			@ui.test.removeClass("is-valid is-invalid")

}
