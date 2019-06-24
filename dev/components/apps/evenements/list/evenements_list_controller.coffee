import { MnObject } from 'backbone.marionette'
import { AlertView, ListPanel, ListLayout } from 'apps/common/common_views.coffee'
import { EvenementsCollectionView_Redacteur, EvenementsCollectionView_Joueur, EditEvenementView } from 'apps/evenements/list/evenements_list_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
	channelName: 'entities'

	listRedacteur: (criterion)->
		criterion = criterion ? ""
		app.trigger "header:loading", true
		listLayout = new ListLayout()
		listPanel = new ListPanel {
			title: "Événements"
			filterCriterion:criterion
			showAddButton: app.Auth.get("rank") is "redacteur"
		}

		channel = @getChannel()

		require "entities/dataManager.coffee"
		Item = require("entities/evenements.coffee").Item

		fetching = channel.request("custom:entities", ["evenements"])
		$.when(fetching).done( (items)->
			listView = new EvenementsCollectionView_Redacteur {
				collection: items
				filterCriterion: criterion
			}

			listPanel.on "items:filter", (filterCriterion)->
				listView.triggerMethod("set:filter:criterion", filterCriterion, { preventRender:false })
				app.trigger("evenements:filter", filterCriterion)

			listLayout.on "render", ->
				listLayout.getRegion('panelRegion').show(listPanel)
				listLayout.getRegion('itemsRegion').show(listView)

			listPanel.on "item:new", ->
				view = new EditEvenementView {
					model: new Item()
					collection: items
					listView: listView
					title: "Nouvel événement"
				}
				app.regions.getRegion('dialog').show(view)

			listView.on "item:edit", (childView, args)->
				model = childView.model
				view = new EditEvenementView {
					model: model
					itemView: childView
					title: "Modification de ##{model.get('id')} : #{model.get('nom')}"
				}
				app.regions.getRegion('dialog').show(view)

			listView.on "item:activation:toggle", (childView)->
				childView.trigger "toggle:attribute", "actif"

			listView.on "item:visible:toggle", (childView)->
				childView.trigger "toggle:attribute", "visible"

			listView.on "item:show", (childView,e) ->
				id = childView.model.get("id")
				app.trigger("evenement:show", id)
			app.regions.getRegion('main').show(listLayout)
		).fail( (response)->
			if response.status is 401
				alert("Vous devez vous (re)connecter !")
				app.trigger("home:logout")
			else
				alertView = new AlertView()
				app.regions.getRegion('main').show(alertView)
		).always( ()->
			app.trigger("header:loading", false)
		)

	listJoueur: (criterion)->
		criterion = criterion ? ""
		app.trigger "header:loading", true
		listLayout = new ListLayout()
		listPanel = new ListPanel {
			title: "Événements"
			filterCriterion: criterion
			showAddButton: false
		}

		channel = @getChannel()

		require "entities/dataManager.coffee"
		Item = require("entities/evenements.coffee").Item

		fetching = channel.request("custom:entities", ["evenements"])
		$.when(fetching).done( (items)->
			listView = new EvenementsCollectionView_Joueur {
				collection: items
				filterCriterion: criterion
			}

			listPanel.on "items:filter", (filterCriterion)->
				listView.triggerMethod("set:filter:criterion", filterCriterion, { preventRender:false })
				app.trigger("evenements:filter", filterCriterion)

			listLayout.on "render", ->
				listLayout.getRegion('panelRegion').show(listPanel)
				listLayout.getRegion('itemsRegion').show(listView)

			listView.on "item:select", (childView,e) ->
				id = childView.model.get("id")
				app.trigger("partie:start", id)
			app.regions.getRegion('main').show(listLayout)
		).fail( (response)->
			if response.status is 401
				alert("Vous devez vous (re)connecter !")
				app.trigger("home:logout")
			else
				alertView = new AlertView()
				app.regions.getRegion('main').show(alertView)
		).always( ->
			app.trigger "header:loading", false
		)
}

export controller = new Controller()
