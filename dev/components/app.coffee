import Marionette from 'backbone.marionette'

Manager = Marionette.Application.extend {
	region: '#app'
	getCurrentRoute: () -> Backbone.history.fragment
	navigate: (route, options) ->
		options or (options = {})
		Backbone.history.navigate(route, options)
	onBeforeStart: (app, options) ->
		RegionContainer = Marionette.View.extend {
			el: "#app-container",
			regions: {
				header: "#header-region"
				ariane: "#ariane-region"
				message: "#message-region"
				main: "#main-region"
				dialog: "#dialog-region"
			}
		}

		@regions = new RegionContainer();

		@regions.getRegion("dialog").onShow = (region,view) ->
			self = @
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
		@version = "1.0.0";
		self = @
		historyStart = () ->
			require('apps/home/app_home.coffee')
			require('apps/ariane/app_ariane.coffee')
			# import des différentes app
			self.trigger "ariane:show"
			self.trigger "header:show"
			if Backbone.history
				Backbone.history.start()
				if self.getCurrentRoute() is ""
					self.trigger "home:show"

		# import de l'appli ariane, entities, session
		require('entities/session.coffee')
		Radio = require('backbone.radio')

		channel = Radio.channel('entities')
		@Ariane = require("entities/ariane.coffee").ArianeController;
		@Auth = channel.request("session:entity", historyStart)
		@settings = {}
}

export app = new Manager()

