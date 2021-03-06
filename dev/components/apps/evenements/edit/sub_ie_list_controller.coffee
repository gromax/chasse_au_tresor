import { MnObject } from 'backbone.marionette'
import { ListLayout } from 'apps/common/common_views.coffee'
import { SubIEListPanel, SubIECollectionView } from 'apps/evenements/edit/sub_ie_list_views.coffee'
import { FilesView } from 'apps/common/files_loader.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities"
  show: (id) ->
    app.trigger "loading:up"
    require "entities/dataManager.coffee"
    channel = @getChannel()

    fetchingData = channel.request("custom:entities", ["evenements", "itemsEvenement", "images"])
    $.when(fetchingData).done( (evenements, itemsEvenement, images)->
      item = itemsEvenement.get(id)
      if item
        idEvenement = item.get 'idEvenement'
        evenement = evenements.get idEvenement
      else evenement = null

      if (item isnt undefined) and (evenement isnt undefined)
        moditem = evenement.get("moditem")
        isshare = evenement.get("isshare")
        layout = new ListLayout()
        panel = new SubIEListPanel { model:item, evenement:evenement }
        subItemsData = item.get "subItemsData"
        try
          d = JSON.parse subItemsData
          if not _.isArray(d) then d = []
        catch e
          d = []
        finally
          SubItemCollection = require("entities/itemsEvenement.coffee").SubItemCollection
          subItemsCollection = new SubItemCollection()
          subItemsCollection.add d, { parse:true }
        subItemsView = new SubIECollectionView { collection: subItemsCollection, redacteurMode: moditem, itemEvenement: item }

        panel.on "navigate:parent", ->
          app.trigger "evenement:show", idEvenement

        subItemsView.on "subItem:edit", (childView)->
          model = childView.model
          if not childView.editMode
            childView.editMode = true
            childView.render()

        subItemsView.on "subItem:image:select", (childView) ->
          imgView = new FilesView { model:evenement, title: "Images de ##{evenement.get('id')}: #{evenement.get('titre')}", items:images, selectButton: true }
          imgView.on "item:select", (v,e)->
            { hash, ext } = v.getSelectedAttr()
            childView.$el.find("input[name='imgUrl']").val("#{hash}.#{ext}")
            imgView.trigger "dialog:close"

          app.regions.getRegion('dialog').show(imgView)

        panel.on "subItem:new", (v,e)->
          type = $(e.currentTarget).attr("type") ? "brut"
          index = subItemsCollection.models.length
          subItemsCollection.add({type, index }, { parse:true })
          item.set("subItemsData", JSON.stringify(subItemsCollection.toJSON()))
          updatingItem = item.save()
          app.trigger "loading:up"
          $.when(updatingItem).done( ->
            newSubItem = subItemsCollection.models[index]
            newSubItemView = subItemsView.children.findByModel(newSubItem)
            newSubItemView.trigger "flash:success"
          ).fail( (response)->
            newSubItem = subItemsCollection.models[index]
            subItemsCollection.remove(newSubItem)
            alert "Erreur inconnue."
          ).always( ->
            app.trigger "loading:down"
          )

        panel.on "files:show", (v)->
          fileView = new FilesView {
            model:evenement
            title:"Images de ##{evenement.get('id')}: #{evenement.get('titre')}"
            items:images
            addFile: moditem
            delFile: !isshare
          }

          fileView.on "item:submit", (formData)->
            Item = require("entities/images.coffee").Item
            nItem = new Item()
            nItem.set("idEvenement", idEvenement)
            uploadingItem = nItem.saveImg(formData)
            app.trigger "loading:up"
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
                  alert "Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur"
            ).always( ->
              app.trigger "loading:down"
            )

          fileView.on "item:delete", (model)->
            if model and confirm("Supprimer l'élément actif ?")
              destroyRequest = model.destroy()
              app.trigger "loading:up"
              $.when(destroyRequest).done( ->
                fileView.refreshList()
                fileView.render()
              ).fail( (response)->
                alert("Erreur. Essayez à nouveau !")
              ).always( ->
                app.trigger "loading:down"
              )

          app.regions.getRegion('dialog').show(fileView)

        layout.on "render", ()->
          layout.getRegion('panelRegion').show(panel)
          layout.getRegion('itemsRegion').show(subItemsView)

        app.regions.getRegion('main').show(layout)
      else
        app.trigger "not:found"
    ).fail( (response) ->
      app.trigger "data:fetch:fail", response
    ).always( () ->
      app.trigger "loading:down"
    )
}

export controller = new Controller()
