import { MnObject } from 'backbone.marionette'
import { ListPanel } from 'apps/common/common_views.coffee'
import { IEListPanel } from 'apps/evenements/edit/ie_list_views.coffee'
import { PartagesCollectionView, PartagesListLayout, PartageAddListItems } from 'apps/evenements/partages/partages_list_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'
  show: (id,criterion)->
    app.trigger "loading:up"
    channel = @getChannel()
    PartageItem = require("entities/partages.coffee").Item
    fetching = channel.request("evenement:partages", id)
    $.when(fetching).done( (evenement, items)->
      listLayout = new PartagesListLayout()
      listView = new PartagesCollectionView {
        collection: items
      }

      entete = new IEListPanel {
        model: evenement
        partagesView: true
      }

      entete.on "navigate:parent", ->
        app.trigger "evenements:list"

      entete.on "navigate:partage", ->
        app.trigger "evenement:show", id

      listPanel = new ListPanel {
        idEvenement: id
        listView
        appTrigger: (view, criterion)->
          app.trigger "evenement:partage", view.getOption("idEvenement"), criterion
        title: "Partages"
        filterCriterion:criterion
        showAddButton:true
      }

      listLayout.on "render", ->
        listLayout.getRegion('enteteRegion').show(entete)
        listLayout.getRegion('panelRegion').show(listPanel)
        listLayout.getRegion('itemsRegion').show(listView)

      listPanel.on "item:new", ->
        fetching = channel.request("evenement:users:nopartages", id)
        app.trigger "loading:up"
        $.when(fetching).done( (users)->
          usersView = new PartageAddListItems { collection:users }
          usersView.on "item:add", (v)->
            model = v.model
            p = new PartageItem {
              nom: v.model.get("nom")
              idEvenement: id
              idRedacteur: v.model.get("id")
            }
            app.trigger "loading:up"
            inserting = p.save()
            $.when(inserting).done( ->
              items.add p
              listView.children.findByModel(p).trigger("flash:success")
              usersView.trigger "dialog:close"
            ).fail( (response)->
              usersView.$el.append("<div class='alert alert-danger' role='alert'>Une erreur est survenue. Réessayez.</div>")
            ).always( ->
              app.trigger "loading:down"
            )
          app.regions.getRegion('dialog').show(usersView)
        ).fail( (response)->
          alert "Une erreur est survenue."
        ).always( ->
          app.trigger "loading:down"
        )

      app.regions.getRegion('main').show(listLayout)
    ).fail( (response)->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )
}

export controller = new Controller()
