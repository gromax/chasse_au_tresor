import { View, CollectionView } from 'backbone.marionette'
import { SortList, DestroyWarn, FlashItem, SubmitClicked, EditItem, FilterList } from 'apps/common/behaviors.coffee'

import ie_list_tpl from 'templates/evenements/edit/list-ie.tpl'
import ie_list_item_view_tpl from 'templates/evenements/edit/list-ie-item.tpl'
import ie_list_none_tpl from 'templates/evenements/edit/list-ie-none.tpl'
import ie_list_panel_tpl from "templates/evenements/edit/list-ie-panel.tpl"
import edit_ie_description_tpl from 'templates/evenements/edit/edit-ie-description.tpl'

IENoItemView = View.extend {
  template:  ie_list_none_tpl
  tagName: "tr"
  className:"table-warning"
}

IEItemView = View.extend {
  tagName: "tr"
  template: ie_list_item_view_tpl
  behaviors: [DestroyWarn, FlashItem]
  triggers: {
    "click a.js-edit": "edit"
    "click": "show"
  }
  templateContext: ->
    {
      moditem: @getOption "moditem"
      isshare: @getOption "isshare"
    }
}

IEListPanel = View.extend {
  template: ie_list_panel_tpl
  partagesView: false
  triggers: {
    "click a.js-parent": "navigate:parent"
    "click a.js-partage": "navigate:partage"
  }
  templateContext: ->
    {
      baseUrl: window.location.href.split("#")[0].slice(0, -1)+"#"
      partagesView: @getOption "partagesView"
    }
}

IECollectionView = CollectionView.extend {
  tagName: "table"
  className:"table table-hover"
  template: ie_list_tpl
  behaviors: [SortList, FilterList]
  filterKeys: ["tagCle", "regexCle"]
  childViewContainer: "tbody"
  childView:IEItemView
  childViewEventPrefix: 'item'
  emptyView: IENoItemView
  moditem: true
  isshare: false

  templateContext: ->
    {
      addButton: @getOption "addButton"
    }

  childViewOptions: ->
    {
      moditem: @getOption "moditem"
      isshare: @getOption "isshare"
    }

  viewFilter: (child, index, collection) ->
    idE = @options.idEvenement
    model = child.model
    return child.model.get("idEvenement") is idE
}

EditIEDescriptionView = View.extend {
  template: edit_ie_description_tpl
  ui: {
    test: 'input.js-test'
    regexCle: '#item-regexCle'
  }
  behaviors: [SubmitClicked, EditItem]
  triggers: {
    "input @ui.test": "test:reload"
    "input @ui.regexCle": "test:reload"
    "click button.js-gps": "set:gps"
  }

  initialize: ->
    @title = @getOption "title"

  onSetGps: ->
    options = {
      enableHighAccuracy: true
      timeout: 5000
      maximumAge: 0
    }
    self = @
    app = require('app').app
    errorFct = (err) ->
      app.trigger "loading:down"
      console.warn("ERREUR (#{err.code}): #{err.message}")

    successFct = (pos) ->
      app.trigger "loading:down"
      crd = pos.coords
      self.ui.regexCle.val("gps=#{crd.latitude},#{crd.longitude}")
    app.trigger "loading:up"
    navigator.geolocation.getCurrentPosition(successFct, errorFct, options)

  onTestReload: ->
    test = @ui.test.val()
    test = test.normalize('NFD').replace(/[\u0300-\u036f\\\s\']/g, "")
    regexCle = @ui.regexCle.val()
    result = false
    if test!="" and regexCle !=""
      try
        # On test si la clé est de type gps
        gpsRegex = /^gps=[0-9]+\.[0-9]+,[0-9]+\.[0-9]+$/
        if gpsRegex.test(regexCle)
          # C'est du gps
          # On commence par tester si le test l'est également
          if gpsRegex.test(test)
            # le test est bien du gps
            # il faut faire le calcul
            # d'abord pour la clé
            a1 = regexCle.split "="
            strCoords = a1[1].split(",")
            coordsCle = {
              y: Number strCoords[0]
              x: Number strCoords[1]
            }
            # même chose pour le test
            a1 = test.split "="
            strCoords = a1[1].split(",")
            coordsTest = {
              y: Number strCoords[0]
              x: Number strCoords[1]
            }
            # ensuite calcul
            dx = 60*(coordsTest.x - coordsCle.x)*Math.cos((coordsCle.y+coordsTest.y)/2*0.01745329251994329577)
            dy = 60*(coordsTest.y - coordsCle.y)
            dist = Math.sqrt(dx*dx + dy*dy)*1852 # exprimé en minutes d'arc^2
            result = (dist <= GPS_LIMIT)
          else
            # le test n'est pas du gps
            result = false
        else
          # Ce n'est pas du gps
          r = new RegExp(regexCle, 'gi')
          result = r.test(test)
      catch e
        result = false
      finally
        if result
          @ui.test.addClass("is-valid")
          @ui.test.removeClass("is-invalid")
        else
          @ui.test.addClass("is-invalid")
          @ui.test.removeClass("is-valid")
    else
      @ui.test.removeClass("is-valid is-invalid")

}


export { IEListPanel, IECollectionView, EditIEDescriptionView }
