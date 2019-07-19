import { MnObject } from 'backbone.marionette'
import { ListPanel, ListLayout } from 'apps/common/common_views.coffee'
import { RedacteursCollectionView } from 'apps/redacteurs/list/redacteurs_list_views.coffee'
import { EditUserView, NewUserView } from 'apps/common/edit_user_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'
  list: (criterion)->
    app.trigger "loading:up"
    channel = @getChannel()
    require "entities/dataManager.coffee"
    fetching = channel.request("custom:entities", ["redacteurs"])
    $.when(fetching).done( (items)->
      listLayout = new ListLayout()
      listView = new RedacteursCollectionView {
        collection: items
      }
      listPanel = new ListPanel {
        listView
        appTrigger: "redacteurs:filter"
        title: "Rédacteurs"
        filterCriterion:criterion
        showAddButton:true
      }

      listLayout.on "render", ->
        listLayout.getRegion('panelRegion').show(listPanel)
        listLayout.getRegion('itemsRegion').show(listView)

      listPanel.on "item:new", ->
        Item = require("entities/redacteurs.coffee").Item
        newItem = new Item()
        view = new NewUserView {
          model: newItem
          title: "Nouveau rédacteur"
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
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )
}

export controller = new Controller()
