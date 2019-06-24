import { MnObject } from 'backbone.marionette'
import { AlertView, ListPanel, ListLayout } from 'apps/common/common_views.coffee'
import { JoueursCollectionView } from 'apps/joueurs/list/joueurs_list_views.coffee'
import { EditUserView } from 'apps/common/edit_user_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'
  list: (criterion)->
    criterion = criterion ? ""
    app.trigger "header:loading", true
    listLayout = new ListLayout()
    listPanel = new ListPanel {
      title: "Joueurs"
      filterCriterion:criterion
      showAddButton:false
    }

    channel = @getChannel()

    require "entities/dataManager.coffee"
    Item = require("entities/joueurs.coffee").Item

    fetching = channel.request("custom:entities", ["joueurs"])
    $.when(fetching).done( (items)->
      listView = new JoueursCollectionView {
        collection: items
      }

      listPanel.on "items:filter", (filterCriterion)->
        listView.triggerMethod("set:filter:criterion", filterCriterion, { preventRender:false })
        app.trigger("joueurs:filter", filterCriterion)

      listLayout.on "render", ()->
        listLayout.getRegion('panelRegion').show(listPanel)
        listLayout.getRegion('itemsRegion').show(listView)

      listView.on "item:edit", (childView)->
        model = childView.model
        view = new EditUserView {
          model: model
          itemView: childView
          showPWD: false
          showInfos: true
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
