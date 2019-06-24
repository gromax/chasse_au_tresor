import { MnObject } from 'backbone.marionette'
import { AlertView, ListPanel, ListLayout } from 'apps/common/common_views.coffee'
import { RedacteursCollectionView } from 'apps/redacteurs/list/redacteurs_list_views.coffee'
import { EditUserView, NewUserView } from 'apps/common/edit_user_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'
  list: (criterion)->
    criterion = criterion ? ""
    app.trigger "header:loading", true
    listLayout = new ListLayout()
    listPanel = new ListPanel {
      title: "Rédacteurs"
      filterCriterion:criterion
      showAddButton:true
    }

    channel = @getChannel()

    require "entities/dataManager.coffee"
    fetching = channel.request("custom:entities", ["redacteurs"])
    $.when(fetching).done( (items)->
      listView = new RedacteursCollectionView {
        collection: items
      }

      listPanel.on "items:filter", (filterCriterion)->
        listView.trigger("set:filter:criterion", filterCriterion, { preventRender:false })
        app.trigger("redacteurs:filter", filterCriterion)

      listView.trigger("set:filter:criterion", criterion, { preventRender:false })

      listLayout.on "render", ->
        listLayout.getRegion('panelRegion').show(listPanel)
        listLayout.getRegion('itemsRegion').show(listView)

      listPanel.on "item:new", ->
        Item = require("entities/redacteurs.coffee").Item
        newItem = new Item()
        view = new NewUserView {
          model: newItem
          title: "Nouveau rédacteur"
          collection: "items"
          listView: listView
        }
        app.regions.getRegion('dialog').show(view)

      listView.on "item:edit", (childView)->
        model = childView.model
        view = new EditUserView {
          model: model
          itemView: childView
          showInfos: true
          showPWD: false
          title: "Modification de ##{model.get('id')} : #{model.get('nom')}"
        }
        app.regions.getRegion('dialog').show(view)

      listView.on "item:editPwd", (childView)->
        model = childView.model
        view = new EditUserView {
          model:model
          itemView: childView
          showInfos: false
          showPWD: true
          title: "Nouveau mot de passe pour ##{model.get('id')} : #{model.get('nom')}"
        }
        app.regions.getRegion('dialog').show(view)
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
