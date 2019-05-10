import Marionette from "backbone.marionette"
import { SignView } from "apps/common/sign/sign_view.coffee"

app = require("app").app

Controller = Marionette.Object.extend {
	channelName: "entities"
	show: (options)->
		if app.Auth.get("logged_in")
			if typeof options?.callback is "function"
				options.callback()
			else
				app.trigger "home:show"
		else
			view = new SignView {
				signin: options?.signin
				showRedacCheck: options?.showRedacCheck
				showToggleButton: options?.showToggleButton
			}

			signinCallback = (data) ->
				openingSession = app.Auth.save(data)
				if openingSession
					app.trigger("header:loading", true)
					# En cas d'échec de connexion, l'api server renvoie une erreur
					$.when(openingSession).done( (response)->
						if typeof options?.callback is "function"
							options.callback()
						else
							app.trigger "home:show"
					).fail( (response)->
						if response.status is 422
							view.triggerMethod("form:data:invalid", response.responseJSON.ajaxMessages);
						else
							alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/025]")
					).always( ()->
						app.trigger("header:loading", false)
					)
				else
					view.triggerMethod("form:data:invalid", app.Auth.validationError)

			signupCallback = (data) ->
				Joueur = require("entities/joueurs.coffee").Item
				nJoueur = new Joueur()
				creatingSession = nJoueur.save(data)
				if creatingSession
					app.trigger("header:loading", true)
					$.when(creatingSession).done( (response)->
						# toutes les infos pour l'ouverture de session devraient être là
						view.options.signin = true
						view.options.username = data.username
						view.options.pwd = data.pwd
						view.render()
						signinCallback { username:data.username, pwd:data.pwd, adm:false }
					).fail( (response)->
						if response.status is 422
							view.triggerMethod("form:data:invalid", response.responseJSON.errors);
						else
							alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/025]")
					).always( ()->
						app.trigger("header:loading", false)
					)
				else
					view.triggerMethod("form:data:invalid", nJoueur.validationError)


			view.on "form:submit", (data) ->
				if view.options.signin is true
					signinCallback(data)
				else
					signupCallback(data)

			app.regions.getRegion('main').show(view);

}

export controller = new Controller()
