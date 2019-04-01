import Marionette from 'backbone.marionette'
import template from 'templates/common/images_loader.tpl'

app = require('app').app

ImagesView = Marionette.View.extend {
  template: template

  triggers: {
    "click a.js-select":"image:select"
  }

  events: {
    "click a.js-suiv":"imageSuivante"
    "click a.js-prec":"imagePrecedente"
  }

  imageSuivante: (e)->
    e.preventDefault()
    n = @filteredList().length
    if n>0
      @index = (@index+1)%n
    else
      @index = 0
    @render()

  imagePrecedente: (e)->
    e.preventDefault()
    n = @filteredList().length
    if n>0
      @index--
      if @index<0 then @index = n-1
    else
      @index = 0
    @render()

  getSelectedHash: ->
    l = @filteredList()
    n = l.length
    if n is 0
      "x"
    else
      l[@index].get('hash')

  initialize: ->
    @title = @options.title or @title or ""
    @index = 0

  filteredList: (purge=false)->
    if (purge or !@_filteredList)
      @_filteredList = @options.images.where({idEvenement: @model.get('id')})
    return @_filteredList

  templateContext: ->
    { hash: @getSelectedHash(), selectButton:@options.selectButton is true }
}

export { ImagesView }
