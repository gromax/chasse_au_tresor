import Marionette from 'backbone.marionette'
import AlertView from 'apps/common/alert_view.coffee'
import MissingView from 'apps/common/missing.coffee'
import { ListeView, Layout, EnteteView } from 'apps/evenements/edit/ie_list_view.coffee'
import FormView from 'apps/evenements/common/formItem_view.coffee'
import { PanelView, ItemLayoutView } from 'apps/evenements/edit/ie_edit_view.coffee'
import { SubItemCollectionView } from 'apps/evenements/common/sub_items_view.coffee'
import { FilesView } from 'apps/common/files_loader.coffee'

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
        layout = new Layout()
        entete = new EnteteView { model: evenement }
        liste = new ListeView { collection: itemsEvenement, idEvenement:evenement.get("id"), addButton: true }

        entete.on "navigate:parent", ->
          app.trigger "evenements:list"

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
        layout = new ItemLayoutView()
        panel = new PanelView({ model:item, evenement:evenement })

        subItemsData = item.get("subItemsData")
        try
          d = JSON.parse(subItemsData)
          if not _.isArray(d) then d = []
        catch e
          d = []
        finally
          SubItemCollection = require("entities/itemsEvenement.coffee").SubItemCollection
          subItemsCollection = new SubItemCollection()
          subItemsCollection.add(d, {parse:true})
        subItemsView = new SubItemCollectionView({ collection: subItemsCollection, redacteurMode:true })

        panel.on "navigate:parent", ->
          app.trigger "evenement:show", idEvenement

        panel.on "type:toggle", () ->
          mtype = item.get("type")
          item.set("type", (mtype+1) % 3)
          savingItem = item.save()
          app.trigger("header:loading", true)
          $.when(savingItem).done( ()->
            panel.render()
          ).fail( (response)->
            switch response.status
              when 401
                alert("Vous devez vous (re)connecter !")
                panel.trigger("dialog:close")
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
              item.set("subItemsData", JSON.stringify(subItemsCollection.toJSON()))
              updatingItem = item.save()
              app.trigger("header:loading", true)
              $.when(updatingItem).done( ()->
              ).fail( (response)->
                switch response.status
                  when 401
                    alert("Vous devez vous (re)connecter !")
                    app.trigger("home:logout")
                  else
                    alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/031]")
              ).always( ()->
                app.trigger("header:loading", false)
              )



        subItemsView.on "subItem:down", (childView)->
          current = childView.model
          index = current.get("index")
          suiv = subItemsCollection.findWhere({index:index+1})
          if suiv
            suiv.set('index', index)
            current.set('index', index+1)
            subItemsCollection.sort()
            item.set("subItemsData", JSON.stringify(subItemsCollection.toJSON()))
            updatingItem = item.save()
            app.trigger("header:loading", true)
            $.when(updatingItem).done( ()->
            ).fail( (response)->
              switch response.status
                when 401
                  alert("Vous devez vous (re)connecter !")
                  app.trigger("home:logout")
                else
                  alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/031]")
            ).always( ()->
              app.trigger("header:loading", false)
            )

        subItemsView.on "subItem:edit", (childView)->
          model = childView.model
          if not childView.editMode
            childView.editMode = true
            childView.render()

        subItemsView.on "subItem:form:submit", (childView, data)->
          model = childView.model
          validationResult = model.set(data, {validate:true})
          if validationResult
            #switch type
            # when "brut"
            #   model.set(data)
            # when "image"
            item.set("subItemsData", JSON.stringify(subItemsCollection.toJSON()))
            updatingItem = item.save()
            app.trigger("header:loading", true)
            $.when(updatingItem).done( ()->
              childView.editMode = false
              childView.render()
              #childView.flash("success")
            ).fail( (response)->
              switch response.status
                when 401
                  alert("Vous devez vous (re)connecter !")
                  app.trigger("home:logout")
                else
                  alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/031]")
            ).always( ()->
              app.trigger("header:loading", false)
            )
          else
            childView.triggerMethod("form:data:invalid",model.validationError)

        subItemsView.on "subItem:delete", (childView,e)->
          model = childView.model
          idItem = model.get("id")
          if confirm("Supprimer l'élément ?")
            model.destroy()
            item.set("subItemsData", JSON.stringify(subItemsCollection.toJSON()))
            destroyRequest = item.save()
            app.trigger("header:loading", true)
            $.when(destroyRequest).done( ()->
              childView.remove()
            ).fail( (response)->
              alert("Erreur. Essayez à nouveau !")
            ).always( ()->
              app.trigger("header:loading", false)
            )

        subItemsView.on "subItem:image:select", (childView) ->
          imgView = new FilesView { model:evenement, title: "Images de ##{evenement.get('id')}: #{evenement.get('titre')}", items:images, selectButton:true }
          imgView.on "item:select", (v,e)->
            { hash, ext } = v.getSelectedAttr()
            childView.$el.find("input[name='imgUrl']").val("#{hash}.#{ext}")
            imgView.trigger("dialog:close")

          app.regions.getRegion('dialog').show(imgView)

        panel.on "subItem:new", (v,e)->
          type = $(e.currentTarget).attr("type") ? "brut"
          index = subItemsCollection.models.length
          subItemsCollection.add({type, index }, { parse:true })
          item.set("subItemsData", JSON.stringify(subItemsCollection.toJSON()))
          updatingItem = item.save()
          app.trigger("header:loading", true)
          $.when(updatingItem).done( ()->
            newSubItem = subItemsCollection.models[index]
            newSubItemView = subItemsView.children.findByModel(newSubItem)
            newSubItemView.flash()
          ).fail( (response)->
            newSubItem = subItemsCollection.models[index]
            subItemsCollection.remove(newSubItem)
            alert("Erreur inconnue.")
          ).always( ()->
            app.trigger("header:loading", false)
          )

        panel.on "files:show", (v)->
          fileView = new FilesView {
            model:evenement
            title:"Images de ##{evenement.get('id')}: #{evenement.get('titre')}"
            items:images
            addFile:true
            delFile:true
          }

          fileView.on "item:submit", (formData)->
            Item = require("entities/images.coffee").Item
            nItem = new Item()
            nItem.set("idEvenement", idEvenement)
            uploadingItem = nItem.saveImg(formData)
            app.trigger("header:loading", true)
            $.when(uploadingItem).done( (response)->
              images.add(nItem)
              fileView.showLast()
            ).fail( (response)->
              switch response.status
                when 401
                  alert("Vous devez vous (re)connecter !")
                  fileView.trigger("dialog:close")
                  app.trigger("home:logout")
                else
                  alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/031]")
            ).always( ()->
              app.trigger("header:loading", false)
            )

          fileView.on "item:delete", (model)->
            if model and confirm("Supprimer l'élément actif ?")
              destroyRequest = model.destroy()
              app.trigger("header:loading", true)
              $.when(destroyRequest).done( ()->
                fileView.refreshList()
                fileView.render()
              ).fail( (response)->
                alert("Erreur. Essayez à nouveau !")
              ).always( ()->
                app.trigger("header:loading", false)
              )

          app.regions.getRegion('dialog').show(fileView)



        layout.on "render", ()->
          layout.getRegion('panelRegion').show(panel)
          layout.getRegion('itemsRegion').show(subItemsView)

        app.regions.getRegion('main').show(layout)
      else
        view = new MissingView()
        app.regions.getRegion('main').show(view)
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
