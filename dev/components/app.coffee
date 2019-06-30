import Marionette from 'backbone.marionette'
import Syphon from 'backbone.syphon'

Manager = Marionette.Application.extend {
	region: '#app'
	ajaxCount: 0
	getCurrentRoute: () -> Backbone.history.fragment
	navigate: (route, options) ->
		options or (options = {})
		Backbone.history.navigate(route, options)
	onBeforeStart: (app, options) ->
		RegionContainer = Marionette.View.extend {
			el: "#app-container",
			regions: {
				header: "#header-region"
				message: "#message-region"
				main: "#main-region"
				dialog: "#dialog-region"
			}
		}

		@regions = new RegionContainer();

		@regions.getRegion("dialog").onShow = (region,view) ->
			self = @
			require 'jquery-ui/dialog.js'
			closeDialog = () ->
				self.stopListening()
				self.empty()
				self.$el.dialog("destroy")
				view.trigger("dialog:closed")
			@listenTo(view, "dialog:close", closeDialog)
			@$el.dialog {
				modal: true
				title: view.title
				width: "auto"
				close: (e, ui) ->
					closeDialog()
			}

	onStart: (app, options) ->
		@version = VERSION
		self = @
		historyStart = () ->
			require('apps/home/app_home.coffee')
			require('apps/redacteurs/app_redacteurs.coffee')
			require('apps/joueurs/app_joueurs.coffee')
			require('apps/evenements/app_evenements.coffee')
			require('apps/parties/app_parties.coffee')
			require('apps/header/app_header.coffee')
			require('apps/common/app_default.coffee')
			# import des différentes app
			self.trigger "header:show"
			if Backbone.history
				Backbone.history.start()
				if self.getCurrentRoute() is ""
					self.trigger "home:show"

		# import de l'appli entities, session
		require('entities/session.coffee')
		Radio = require('backbone.radio')

		channel = Radio.channel('entities')
		@Auth = channel.request("session:entity", historyStart)
		@settings = {}
}

export app = new Manager()

