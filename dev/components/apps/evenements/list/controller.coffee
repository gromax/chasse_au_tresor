import { MnObject } from 'backbone.marionette'
import { AlertView } from 'apps/common/commons_view.coffee'
import { Layout, Panel } from 'apps/common/list.coffee'
import { RedacteurListView, JoueurListView } from 'apps/evenements/list/view.coffee'
import FormView from 'apps/evenements/common/form_view.coffee'

app = require('app').app

Controller = MnObject.extend {
	channelName: 'entities'

	listRedacteur: (criterion)->
		criterion = criterion ? ""
		app.trigger("header:loading", true)
		listLayout = new Layout()
		listPanel = new Panel {
			title: "Événements"
			filterCriterion:criterion
			showAddButton: app.Auth.get("rank") is "redacteur"
		}

		channel = @getChannel()

		require "entities/dataManager.coffee"
		Item = require("entities/evenements.coffee").Item

		fetching = channel.request("custom:entities", ["evenements"])
		$.when(fetching).done( (items)->
			listView = new RedacteurListView {
				collection: items
				filterCriterion: criterion
			}

			listPanel.on "items:filter", (filterCriterion)->
				listView.triggerMethod("set:filter:criterion", filterCriterion, { preventRender:false })
				app.trigger("evenements:filter", filterCriterion)

			listLayout.on "render", ()->
				listLayout.getRegion('panelRegion').show(listPanel)
				listLayout.getRegion('itemsRegion').show(listView)

			listPanel.on "item:new", ()->
				newItem = new Item()
				view = new FormView {
					model: newItem
					title: "Nouvel événement"
				}

				view.on "form:submit", (data)->
					# Dans ce qui suit, le handler error sert s'il y a un problème avec la requête
					# Mais la fonction renvoie false directement si le save n'est pas permis pour ne pas vérifier des conditions comme un terme vide
					savingItem = newItem.save(data)
					if savingItem
						app.trigger("header:loading", true)
						$.when(savingItem).done( ()->
							items.add(newItem)
							view.trigger("dialog:close")
							newItemView = listView.children.findByModel(newItem)
							# check whether the new user view is displayed (it could be
							# invisible due to the current filter criterion)
							if newItemView
								newItemView.flash("success")
						).fail( (response)->
							switch response.status
								when 422
									view.triggerMethod("form:data:invalid", response.responseJSON.errors)
								when 401
									alert("Vous devez vous (re)connecter !")
									view.trigger("dialog:close")
									app.trigger("home:logout")
								else
									alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/030]")
						).always(()->
							app.trigger("header:loading", false)
						)
					else
						view.triggerMethod("form:data:invalid",newItem.validationError)

				app.regions.getRegion('dialog').show(view)

			listView.on "item:edit", (childView, args)->
				model = childView.model
				view = new FormView {
					model: model
					showInfos: true
					showPWD: false
					title: "Modification de ##{model.get('id')} : #{model.get('nom')}"
				}

				view.on "form:submit", (data)->
					updatingItem = model.save(data)
					app.trigger("header:loading", true)
					if updatingItem
						$.when(updatingItem).done( ()->
							childView.render()
							view.trigger("dialog:close")
							childView.flash("success")
						).fail( (response)->
							switch response.status
								when 422
									view.triggerMethod("form:data:invalid", response.responseJSON.errors)
								when 401
									alert("Vous devez vous (re)connecter !")
									view.trigger("dialog:close")
									app.trigger("home:logout")
								else
									alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/031]")
						).always( ()->
							app.trigger("header:loading", false)
						)
					else
						@triggerMethod("form:data:invalid", model.validationError)

				app.regions.getRegion('dialog').show(view)

			listView.on "item:activation:toggle", (childView)->
				model = childView.model
				model.set("actif", not model.get("actif"))
				updatingItem = model.save()
				app.trigger("header:loading", true)
				$.when(updatingItem).done( ()->
					childView.render()
					childView.flash("success")
				).fail( (response)->
					switch response.status
						when 401
							alert("Vous devez vous (re)connecter !")
							view.trigger("dialog:close")
							app.trigger("home:logout")
						else
							alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/031]")
				).always( ()->
					app.trigger("header:loading", false)
				)

			listView.on "item:visible:toggle", (childView)->
				model = childView.model
				model.set("visible", not model.get("visible"))
				updatingItem = model.save()
				app.trigger("header:loading", true)
				$.when(updatingItem).done( ()->
					childView.render()
					childView.flash("success")
				).fail( (response)->
					switch response.status
						when 401
							alert("Vous devez vous (re)connecter !")
							view.trigger("dialog:close")
							app.trigger("home:logout")
						else
							alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/031]")
				).always( ()->
					app.trigger("header:loading", false)
				)

			listView.on "item:delete", (childView)->
				model = childView.model
				destroyRequest = model.destroy()
				app.trigger("header:loading", true)
				$.when(destroyRequest).done( ()->
					childView.trigger "remove"
				).fail( (response)->
					alert("Erreur. Essayez à nouveau !")
				).always( ()->
					app.trigger("header:loading", false)
				)

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
		app.trigger("header:loading", true)
		listLayout = new Layout()
		listPanel = new Panel {
			title: "Événements"
			filterCriterion:criterion
			showAddButton: false
		}

		channel = @getChannel()

		require "entities/dataManager.coffee"
		Item = require("entities/evenements.coffee").Item

		fetching = channel.request("custom:entities", ["evenements"])
		$.when(fetching).done( (items)->
			listView = new JoueurListView {
				collection: items
				filterCriterion: criterion
			}

			listPanel.on "items:filter", (filterCriterion)->
				listView.triggerMethod("set:filter:criterion", filterCriterion, { preventRender:false })
				app.trigger("evenements:filter", filterCriterion)

			listLayout.on "render", ()->
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
		).always( ()->
			app.trigger("header:loading", false)
		)
}

export controller = new Controller()
