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

	validate: (attrs, options)->
		errors = []
		if not attrs.identifiant
			errors.push { success:false, message:"L'email ne doit pas être vide" }
		if not attrs.pwd
			errors.push { success:false, message:"Le mot de passe ne doit pas être vide" }
		if not _.isEmpty(errors)
			return errors

	toJSON: ->
		return {
			identifiant: @get("identifiant")
			pwd: @get("pwd")
		}

	parse: (data)->
		if data.logged
			logged = data.logged
		else
			logged = data
		return logged

	refresh: (data)->
		@set(@parse(data))

	getAuth: (callback)->
		# getAuth is wrapped around our router
		# before we start any routers let us see if the user is valid
		@fetch({
			success: callback
		})

	getWithForgottenKey: (key) ->
		that = @
		defer = $.Deferred()
		request = $.ajax("api/forgotten/"+key,{
			method:'GET'
			dataType:'json'
		})
		request.done( (response)->
			that.refresh(response)
			defer.resolve()
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
		Auth.getAuth(callback)
		return Auth

	sendForgottenEmail: (email)->
		return request = $.ajax(
			"api/forgotten",
			{
				method:'POST'
				dataType:'json'
				data: { email:email }
			}
		)
}

channel = Radio.channel('entities')
channel.reply('session:entity', API.getSession )
channel.reply('forgotten:password', API.sendForgottenEmail )

module.exports = Session
