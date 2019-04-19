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
		if not attrs.email
			errors.push { success:false, message:"L'email/identifiant ne doit pas être vide" }
		if not attrs.pwd
			errors.push { success:false, message:"Le mot de passe ne doit pas être vide" }
		if not _.isEmpty(errors)
			return errors

	toJSON: ->
		return {
			email: @get("email")
			pwd: @get("pwd")
			adm: @get("adm")
		}

	parse: (data)->
		if data.logged
			logged = data.logged
		else
			logged = data
		if logged?.rank is "root" then logged.id = -1 # sinon l'élément est considéré nouveau et sa destruction ne provoque pas de requête DELETE
		logged.adm = (logged.adm is true) or (logged.rank is "redacteur") or (logged.rank is "root")
		return logged

	refresh: (data)->
		@set(@parse(data))

	getAuth: (callback)->
		# getAuth is wrapped around our router
		# before we start any routers let us see if the user is valid
		@fetch({
			success: callback
		})
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
