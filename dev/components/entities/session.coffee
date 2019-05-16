import Backbone from 'backbone'
import Radio from 'backbone.radio'

Session = Backbone.Model.extend {
	urlRoot: "api/session"
	initialize: ->
		that = @
		# Hook into jquery
		# Use withCredentials to send the server cookies
		# The server must allow this through response headers
		$.ajaxPrefilter( ( options, originalOptions, jqXHR) ->
			options.xhrFields = {
				withCredentials: true
			}
		)

	default: {
		adm: false
	}

	validate: (attrs, options)->
		errors = []
		if not attrs.username
			errors.push { success:false, message:"L'email/identifiant ne doit pas être vide" }
		if not attrs.pwd
			errors.push { success:false, message:"Le mot de passe ne doit pas être vide" }
		if not _.isEmpty(errors)
			return errors

	toJSON: ->
		return {
			username: @get("username")
			pwd: @get("pwd")
			adm: @get("adm")
		}

	parse: (logged)->
		if logged.rank isnt "off"
			logged.logged_in = true
			if logged?.rank is "root" then logged.id = -1 # sinon l'élément est considéré nouveau et sa destruction ne provoque pas de requête DELETE
			logged.adm = (logged.adm is true) or (logged.rank is "redacteur") or (logged.rank is "root")
		else
			logged = {
				id:-1
				logged_in: false
				rank:"off"
				nom:"Déconnecté"
				username: ""
				adm: false
			}
		return logged

	refresh: (data)->
		@set(@parse(data))

	getAuth: (callback)->
		# getAuth is wrapped around our router
		# before we start any routers let us see if the user is valid
		@fetch({
			success: callback
		})

	sendReinitEmail: (email, redacteurUser) ->
		defer = $.Deferred()
		if redacteurUser is true
			type = "redacteur"
		else
			type = "joueur"
		request = $.ajax("api/#{type}/forgotten",{
			method:'POST'
			dataType:'json'
			data: { email }
		})

		request.done( (response)->
			defer.resolve(response)
		).fail( (response)->
			defer.reject(response)
		)
		return defer.promise()

	getSessionWithHash: (hash, adm) ->
		defer = $.Deferred()
		if adm is true
			url = "api/redacteur/forgotten/#{hash}"
		else
			url = "api/joueur/forgotten/#{hash}"
		request = $.ajax(url,{
			method:'GET'
			dataType:'json'
		})
		request.done( (response)->
			defer.resolve(response)
		).fail( (response)->
			defer.reject(response)
		)
		return defer.promise()

}

API = {
	getSession: (callback)->
		Auth = new Session()
		Auth.on "destroy", ()->
			@unset("id")
			channel = Radio.channel('entities')
			channel.request("data:purge")
			@set("adm",false)
		Auth.getAuth(callback)
		return Auth

}

channel = Radio.channel('entities')
channel.reply('session:entity', API.getSession )

module.exports = Session
