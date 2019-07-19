import { Behavior } from 'backbone.marionette'
import Syphon from 'backbone.syphon'

SortList = Behavior.extend {
  events: {
    "click a.js-sort":"sortFct"
  }

  sortFct: (e)->
    e.preventDefault()
    @view.$el.find(".js-sort-icon").remove()
    $sortEl = $(e.currentTarget)
    tag = $sortEl.attr("sort")
    collection = @view.collection
    if collection.comparatorAttr is tag
      $sortEl.append("<span class='js-sort-icon'>&nbsp;<i class='fa fa-sort-amount-desc'></i></span>")
      collection.comparatorAttr = "inv_"+tag
      collection.comparator = (a,b)->
        if a.get(tag)>b.get(tag)
          -1
        else
          1
    else
      $sortEl.append("<span class='js-sort-icon'>&nbsp;<i class='fa fa-sort-amount-asc'></i></span>")
      collection.comparatorAttr = tag
      collection.comparator = tag
    collection.sort()
}

FilterList = Behavior.extend {
  initialize: ->
    filterCriterion = @view.getOption("filterCriterion") or ""
    if (filterCriterion isnt "")
      @view.trigger("set:filter:criterion",filterCriterion, { preventRender: true })
  onSetFilterCriterion: (criterion, options) ->
    criterion = criterion.normalize('NFD').replace(/\+/g," ").replace(/[\u0300-\u036f]/g, "").toLowerCase()
    if criterion is "" or typeof @view.filterKeys is "undefined"
      @view.removeFilter(options)
    else
      filterKeys = @view.filterKeys
      parseFct = (model) ->
        reductionFct = (m,k) ->
          m+model.get(k)
        _.reduce(filterKeys, reductionFct, "").normalize('NFD').replace(/[\u0300-\u036f]/g, "").toLowerCase()
      filterFct = (view, index, children) ->
        parseFct(view.model).indexOf(criterion) isnt -1
      @view.setFilter(filterFct, options)
}

DestroyWarn = Behavior.extend {
  ui: {
    destroy: '.js-delete'
  }

  events: {
    'click @ui.destroy': 'warnBeforeDestroy'
  }

  warnBeforeDestroy: (e) ->
    e.preventDefault()
    e.stopPropagation() # empêche la propagation d'un click à l'élément parent dans le dom
    model = @view.model
    message = "Supprimer l'élément ##{model.get("id")} ?"
    if confirm(message)
      app = require('app').app
      destroyRequest = model.destroy()
      app.trigger "loading:up"
      view = @view
      $.when(destroyRequest).done( ->
        view.$el.fadeOut( ->
          view.trigger("model:destroy", view.model)
          view.remove()
        )
      ).fail( (response)->
        alert("Erreur. Essayez à nouveau !")
      ).always( ->
        app.trigger "loading:down"
      )
}

SubmitClicked = Behavior.extend {
  ui: {
    submit: 'button.js-submit'
  }
  messagesDivId: "messages"
  events: {
    'click @ui.submit': 'submitClicked'
  }

  submitClicked: (e) ->
    e.preventDefault()
    e.stopPropagation() # empêche la propagation d'un click à l'élément parent dans le dom
    data = Syphon.serialize(@)
    @view.trigger("form:submit", data)
  clearForm: ->
    $view = @view.$el
    $(".is-invalid",$view).each -> $(@).removeClass("is-invalid")
    #$(".is-valid",$view).each -> $(@).removeClass("is-valid")
    $view.find("div.alert").each -> $(@).remove()
    $view.find(".invalid-feedback.d-block").remove()
  onFormDataValid: ->
    # nettoyage d'erreurs précédentes
    @clearForm()
  onFormDataInvalid: (errors) ->
    $view = @view.$el
    messagesDivId = @getOption "messagesDivId"
    if $.isArray(errors)
      $messagesContainer = $("##{messagesDivId}",$view)
      unless $messagesContainer
        $messagesContainer = $view.append "<div id='#{messagesDivId}'></div>"
      markErrors = (value)->
        $errorEl
        if value.success
          $errorEl = $("<div>", { class: "alert alert-success", role:"alert", text: value.message })
        else
          $errorEl = $("<div>", { class: "alert alert-danger", role:"alert", text: value.message })
        $messagesContainer.append $errorEl
    else
      markErrors = (value, key) ->
        $inp = $view.find("input[name='#{key}']")
        if $.isArray(value)
          reduceFct = (m,v,i) -> m+"<p>#{v}</p>"
          html = _.reduce(value, reduceFct, "")
        else
          html = value
        $feedback = $inp.siblings('.invalid-feedback').first()
        if $feedback.length is 0
          $parent = $inp.closest('.form-group')
          $feedback = $("<div class='invalid-feedback d-block'></div>").appendTo($parent)
        $feedback.html html
        $inp.addClass("is-invalid")
    # nettoyage d'erreurs précédentes
    @clearForm()
    _.each(errors, markErrors)
}

FlashItem = Behavior.extend {
  onFlashSuccess: ->
    @flash("success")
  onFlashError: ->
    @flash("danger")
  flash: (cssClass) ->
    $view = @$el
    if @view.tagName is "tr"
      preCss = "table-" # dans Bootstrap
    else
      if "@view.className" is "card"
        preCss = "border-"
      else
        preCss = ""
    $view.hide().toggleClass(preCss+cssClass).fadeIn(800, ()->
      setTimeout( ()->
        $view.toggleClass(preCss+cssClass)
      , 500)
    )
}

ToggleItemValue = Behavior.extend {
  onToggleAttribute: (attributeName) ->
    model = @view.model
    attributeValue = model.get(attributeName)
    model.set(attributeName, !attributeValue)
    updatingItem = model.save()
    self = @
    if updatingItem
      app = require('app').app
      app.trigger "loading:up"
      $.when(updatingItem).done( ->
        self.view.render()
        self.view.trigger "flash:success"
      ).fail( (response)->
        if response.status is 401
          alert "Vous devez vous (re)connecter !"
          app.trigger "home:logout"
        else
          if errorCode = self.view.getOption("errorCode")
            errorCode = "/#{errorCode}"
          else
            errorCode = ""
          alert "Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}#{errorCode}]"
      ).always( ->
        app.trigger "loading:down"
      )
    else
      @view.trigger "flash:error"
}

EditItem = Behavior.extend {
  updatingFunctionName: "save"
  onFormSubmit: (data)->
    fct = @view.getOption "onFormSubmit"
    if (typeof fct is "function")
      fct(data)
    else
      @view.trigger "edit:submit", data
  onEditSubmit: (data)->
    model = @view.model
    # éventuellement une création, si on a fourni "collection"
    updatingFunctionName = @getOption "updatingFunctionName"
    updatingItem = model[updatingFunctionName](data)
    if updatingItem
      app = require('app').app
      app.trigger "loading:up"
      view = @view
      $.when(updatingItem).done( ->
        itemView = view.getOption("itemView")
        listView = view.getOption("listView")
        itemView?.render() # cas d'une itemView existante
        if (collection=listView?.collection) and not collection.get(model.get("id"))
          # c'est un ajout
          collection.add model
        view.trigger "dialog:close" # si ce n'est pas une vue dialog, le trigger ne fait rien
        # soit itemView éxistait et on flash direct
        itemView?.trigger("flash:success")
        # soit on a fournit la liste et on flash via la liste
        listView?.children.findByModel(model)?.trigger("flash:success")
        view.trigger "form:data:valid"
        onSuccess = view.getOption("onSuccess")
        onSuccess?(model,data)
      ).fail( (response)->
        switch response.status
          when 422
            view.trigger "form:data:invalid", response.responseJSON.errors
          when 401
            alert("Vous devez vous (re)connecter !")
            view.trigger("dialog:close")
            app.trigger("home:logout")
          else
            if errorCode = view.getOption("errorCode")
              errorCode = "/#{errorCode}"
            else
              errorCode = ""
            alert "Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}#{errorCode}]"
      ).always( ->
        app.trigger "loading:down", false
      )
    else
      @view.trigger "form:data:invalid",model.validationError
}

FilterPanel = Behavior.extend {
  ui: {
    criterion: "input.js-filter-criterion"
    form: "#filter-form"
  }
  events: {
    "submit @ui.form": "applyFilter"
  }
  initialize: ->
    filterCriterion = @view.getOption("filterCriterion") or ""
    @view.options.filterCriterion = filterCriterion.replace(/\+/g," ")
  applyFilter: (e)->
    # à partir du input
    e.preventDefault()
    criterion = @ui.criterion.val()
    criterionForNav = criterion.replace(/\s/g,"+")
    @triggerListView(criterion, criterionForNav)
  onSetFilterCriterion: (criterion)->
    # par un événement
    criterionForNav = criterion.replace(/\s/g,"+")
    @ui.criterion.val(criterion)
    @triggerListView(criterion, criterionForNav)
  triggerListView: (criterion, criterionForNav) ->
    @view.getOption("listView")?.triggerMethod("set:filter:criterion", criterion, { preventRender:false })
    appTrigger = @view.getOption("appTrigger")
    if typeof appTrigger is "string"
      require('app').app.trigger(appTrigger, criterionForNav)
    else if typeof appTrigger is "function"
      appTrigger(@view, criterionForNav)

}

export { SortList, FilterList, DestroyWarn, SubmitClicked, FlashItem, ToggleItemValue, FilterPanel, EditItem }
