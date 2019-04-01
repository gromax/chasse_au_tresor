import Marionette from 'backbone.marionette'
import AlertView from 'apps/common/alert_view.coffee'
import MissingView from 'apps/common/missing.coffee'
import { ListeView, Layout, EnteteView } from 'apps/evenements/edit/list.coffee'
import FormView from 'apps/evenements/common/formItem_view.coffee'
import { ItemPanelView, SubItemCollectionView, ItemLayoutView } from 'apps/evenements/edit/itemEvenement_view.coffee'
import { ImagesView } from 'apps/common/images_loader.coffee'

app = require('app').app

Controller = Marionette.Object.extend {
	channelName: "entities",
	show: (id) ->
		app.trigger("header:loading", true)

		require "entities/dataManager.coffee"
		channel = @getChannel()

		fetchingData = channel.request("custom:entities", ["evenements", "itemsEvenement"])
		$.when(fetchingData).done( (evenements, itemsEvenement)->
			evenement = evenements.get(id)
			if evenement isnt  undefined
				app.Ariane.add [{ text:evenement.get("titre")}]
				layout = new Layout()
				entete = new EnteteView { model: evenement }
				liste = new ListeView { collection: itemsEvenement, idEvenement:evenement.get("id"), addButton: true }

				liste.on "item:new", ()->
					Item = require("entities/itemsEvenement.coffee").Item
					newItem = new Item()
					view = new FormView {
						model: newItem
						title: "Nouvel item"
					}

					view.on "form:submit", (data)->
						data.idEvenement = id
						savingItem = newItem.save(data)
						if savingItem
							app.trigger("header:loading", true)
							$.when(savingItem).done( ()->
								itemsEvenement.add(newItem)
								view.trigger("dialog:close")
								newItemView = liste.children.findByModel(newItem)
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


				liste.on "item:type:toggle", (childView) ->
					model = childView.model
					mtype = model.get("type")
					model.set("type", (mtype+1) % 3)
					savingItem = model.save()
					app.trigger("header:loading", true)
					$.when(savingItem).done( ()->
						childView.render()
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
								alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/030]")
					).always(()->
						app.trigger("header:loading", false)
					)

				liste.on "item:edit", (childView) ->
					model = childView.model
					view = new FormView {
						model: model
						title: "Modification de ##{model.get('id')}"
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

				liste.on "item:delete", (childView) ->
					model = childView.model
					idItem = model.get("id")
					if confirm("Supprimer ##{idItem} ?")
						destroyRequest = model.destroy()
						app.trigger("header:loading", true)
						$.when(destroyRequest).done( ()->
							childView.remove()
						).fail( (response)->
							alert("Erreur. Essayez à nouveau !")
						).always( ()->
							app.trigger("header:loading", false)
						)

				liste.on "item:show", (childView) ->
					model = childView.model
					idItem = model.get("id")
					idEvenement = model.get("idEvenement")
					app.trigger("evenement:cle:show", idEvenement, idItem)

				layout.on "render", ()->
					layout.getRegion('enteteRegion').show(entete)
					layout.getRegion('itemsRegion').show(liste)
				app.regions.getRegion('main').show(layout)
			else
				view = new MissingView()
				app.regions.getRegion('main').show(view)
				app.Ariane.add([{ text:"Inconnu"}])
		).fail( (response) ->
			if response.status is 401
				alert("Vous devez vous (re)connecter !")
				app.trigger("home:logout")
			else
				alertView = new AlertView()
				app.regions.getRegion('main').show(alertView)
		).always( () ->
			app.trigger("header:loading", false)
		)

	showItem: (id) ->
		app.trigger("header:loading", true)

		require "entities/dataManager.coffee"
		channel = @getChannel()

		fetchingData = channel.request("custom:entities", ["evenements", "itemsEvenement", "images"])
		$.when(fetchingData).done( (evenements, itemsEvenement, images)->
			item = itemsEvenement.get(id)

			if item isnt  undefined
				idEvenement = item.get('idEvenement')
				evenement = evenements.get(idEvenement)
			else evenement = null

			if (item isnt undefined) and (evenement isnt undefined)
				app.Ariane.add [
					{ text:evenement.get("titre"), e:"evenement:show", data:idEvenement, link:"evenement:#{idEvenement}"}
					{ text: "clé ##{id}", e:"evenement:cle:show", data:id, link:"evenements:#{idEvenement}/cle:#{id}"}
				]
				layout = new ItemLayoutView()
				view = new ItemPanelView({ model:item })
				subItemsCollection = item.get("subCollection")
				subItemsView = new SubItemCollectionView({ collection: subItemsCollection })

				view.on "type:toggle", () ->
					mtype = item.get("type")
					item.set("type", (mtype+1) % 3)
					savingItem = item.save()
					app.trigger("header:loading", true)
					$.when(savingItem).done( ()->
						view.render()
					).fail( (response)->
						switch response.status
							when 401
								alert("Vous devez vous (re)connecter !")
								view.trigger("dialog:close")
								app.trigger("home:logout")
							else
								alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/030]")
					).always(()->
						app.trigger("header:loading", false)
					)

				subItemsView.on "subItem:up", (childView)->
					current = childView.model
					index = current.get("index")
					if index>0
						prev = subItemsCollection.findWhere({index:index-1})
						if prev
							prev.set('index', index)
							current.set('index', index-1)
							subItemsCollection.sort()

				subItemsView.on "subItem:down", (childView)->
					current = childView.model
					index = current.get("index")
					suiv = subItemsCollection.findWhere({index:index+1})
					if suiv
						suiv.set('index', index)
						current.set('index', index+1)
						subItemsCollection.sort()

				subItemsView.on "subItem:edit", (childView)->
					model = childView.model
					if not model.get("editMode")
						model.set("editMode", true)
						childView.render()

				subItemsView.on "subItem:form:submit", (childView, data)->
					model = childView.model
					type = model.get("type")
					model.set(data)
					#switch type
					#	when "brut"
					#		model.set(data)
					#	when "image"


					updatingItem = item.save()
					app.trigger("header:loading", true)
					$.when(updatingItem).done( ()->
						model.set("editMode", false)
						childView.render()
						#childView.flash("success")
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

				subItemsView.on "subItem:delete", (childView,e)->
					model = childView.model
					idItem = model.get("id")
					if confirm("Supprimer l'élément ?")
						model.destroy()
						destroyRequest = item.save()
						app.trigger("header:loading", true)
						$.when(destroyRequest).done( ()->
							childView.remove()
						).fail( (response)->
							alert("Erreur. Essayez à nouveau !")
						).always( ()->
							app.trigger("header:loading", false)
						)

				subItemsView.on "subItem:image", (childView) ->
					console.log "pwet"
					imgView = new ImagesView { model:evenement, title: "Images de ##{evenement.get('id')}: #{evenement.get('titre')}", images:images, selectButton:true }
					imgView.on "image:select", (v,e)->
						childView.$el.find("input[name='imgUrl']").val(v.getSelectedHash())
						imgView.trigger("dialog:close")
					app.regions.getRegion('dialog').show(imgView)

				view.on "subItem:new", (v,e)->
					type = $(e.currentTarget).attr("type") ? "brut"
					index = subItemsCollection.models.length
					subItemsCollection.add({type, index, editMode:true}, { parse:true })
					updatingItem = item.save()
					app.trigger("header:loading", true)
					$.when(updatingItem).done( ()->
						newSubItem = subItemsCollection.models[index]
						newSubItemView = subItemsView.children.findByModel(newSubItem)
						newSubItemView.flash()
					).fail( (response)->
						alert("Erreur inconnue.")
					).always( ()->
						app.trigger("header:loading", false)
					)

				view.on "images:show", (v,e)->
					imgView = new ImagesView { model:evenement, title: "Images de ##{evenement.get('id')}: #{evenement.get('titre')}", images:images }
					app.regions.getRegion('dialog').show(imgView)

				layout.on "render", ()->
					layout.getRegion('panelRegion').show(view)
					layout.getRegion('itemsRegion').show(subItemsView)

				app.regions.getRegion('main').show(layout)
			else
				view = new MissingView()
				app.regions.getRegion('main').show(view)
				app.Ariane.add([{ text:"Inconnu"}])
		).fail( (response) ->
			if response.status is 401
				alert("Vous devez vous (re)connecter !")
				app.trigger("home:logout")
			else
				alertView = new AlertView()
				app.regions.getRegion('main').show(alertView)
		).always( () ->
			app.trigger("header:loading", false)
		)

}

export controller = new Controller()
