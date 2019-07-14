import { MnObject } from 'backbone.marionette'
import { ListPanel, ListLayout } from 'apps/common/common_views.coffee'
import { JoueursCollectionView } from 'apps/joueurs/list/joueurs_list_views.coffee'
import { EditUserView } from 'apps/common/edit_user_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'
  list: (criterion)->
    app.trigger "loading:up"
    channel = @getChannel()
    require "entities/dataManager.coffee"
    fetching = channel.request("custom:entities", ["joueurs"])
    $.when(fetching).done( (items)->
      listLayout = new ListLayout()
      listView = new JoueursCollectionView {
        collection: items
        filterCriterion: criterion
      }
      listPanel = new ListPanel {
        listView
        title: "Joueurs"
        filterCriterion:criterion
        showAddButton:false
      }

      listLayout.on "render", ->
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
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )
}

export controller = new Controller()
