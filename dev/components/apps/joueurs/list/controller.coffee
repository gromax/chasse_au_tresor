import Marionette from 'backbone.marionette'
import AlertView from 'apps/common/alert_view.coffee'
import { Layout, Panel } from 'apps/common/list.coffee'
import ListView from 'apps/joueurs/list/view.coffee'
import FormView from 'apps/common/form_user_view.coffee'

app = require('app').app

Controller = Marionette.Object.extend {
	channelName: 'entities'

	list: (criterion)->
		criterion = criterion ? ""
		app.trigger("header:loading", true)
		listLayout = new Layout()
		listPanel = new Panel {
			title: "Joueurs"
			filterCriterion:criterion
			showAddButton:false
		}

		channel = @getChannel()

		require "entities/dataManager.coffee"
		Item = require("entities/joueurs.coffee").Item

		fetching = channel.request("custom:entities", ["joueurs"])
		$.when(fetching).done( (items)->
			listView = new ListView {
				collection: items
				filterCriterion: criterion
			}

			listPanel.on "items:filter", (filterCriterion)->
				listView.triggerMethod("set:filter:criterion", filterCriterion, { preventRender:false })
				app.trigger("joueurs:filter", filterCriterion)

			listLayout.on "render", ()->
				listLayout.getRegion('panelRegion').show(listPanel)
				listLayout.getRegion('itemsRegion').show(listView)

			listView.on "item:edit", (childView, args)->
				model = childView.model
				view = new FormView {
					model: model
					showPWD: false
					showInfos: true
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

			listView.on "item:editPwd", (childView, args)->
				model = childView.model
				view = new FormView {
					model:model
					showInfos: false
					showPWD: true
					title: "Nouveau mot de passe pour ##{model.get('id')} : #{model.get('nom')}"
				}

				view.on "form:submit", (data)->
					if data.pwd isnt data.pwdConfirm
						view.triggerMethod("form:data:invalid", { pwdConfirm:"Les mots de passe sont différents."})
					else
						updatingItem = model.save(_.omit(data,"pwdConfirm"))
						app.trigger("header:loading", true)
						if updatingItem
							$.when(updatingItem).done( ()->
								# Supprimer pwd de user
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
										alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/032]")
							).always( ()->
								app.trigger("header:loading", false)
							)
						else
							@triggerMethod("form:data:invalid", model.validationError)

				app.regions.getRegion('dialog').show(view)

			listView.on "item:delete", (childView,e)->
				model = childView.model
				idItem = model.get("id")
				if confirm("Supprimer le compte de « ##{idItem} : #{model.get('nom')} » ?")
					destroyRequest = model.destroy()
					app.trigger("header:loading", true)
					$.when(destroyRequest).done( ()->
						childView.remove()
					).fail( (response)->
						alert("Erreur. Essayez à nouveau !")
					).always( ()->
						app.trigger("header:loading", false)
					)
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
