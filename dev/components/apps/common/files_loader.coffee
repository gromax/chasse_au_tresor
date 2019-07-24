import { View } from 'backbone.marionette'
import templateImages from 'templates/common/images_loader.tpl'

app = require('app').app

FilesView = View.extend {
  template: templateImages

  triggers: {
    "click a.js-select":"item:select"
  }

  events: {
    "click a.js-suiv":"itemSuivant"
    "click a.js-prec":"itemPrecedent"
    "click button.js-submit":"formSubmit"
    "click button.js-delete":"deleteItem"
  }

  deleteItem: (e)->
    e.preventDefault()
    @trigger("item:delete", @getSelectedItemModel())

  refreshList: ->
    l = @filteredList(true)
    @index = Math.min(l.length-1, @index)

  formSubmit: (e)->
    e.preventDefault()
    $form=@$el.find('form')
    data = new FormData($form.get(0))
    @trigger("item:submit",data)

  itemSuivant: (e)->
    e.preventDefault()
    n = @filteredList().length
    if n>0
      @index = (@index+1)%n
    else
      @index = 0
    @render()

  itemPrecedent: (e)->
    e.preventDefault()
    n = @filteredList().length
    if n>0
      @index--
      if @index<0 then @index = n-1
    else
      @index = 0
    @render()

  showLast: ->
    n = @filteredList(true).length
    if n>0
      @index = n-1
    else
      @index = 0
    @render()

  getSelectedAttr: ->
    l = @filteredList()
    n = l.length
    if n is 0
      {
        hash: ""
        ext: ""
      }
    else
      {
        hash: l[@index].get('hash')
        ext: l[@index].get('ext').toLowerCase()
      }

  getSelectedItemModel: ->
    l = @filteredList()
    n = l.length
    if n is 0
      null
    else
      l[@index]

  initialize: ->
    @title = @options.title or @title or ""
    @index = 0

  filteredList: (purge=false)->
    if (purge or !@_filteredList)
      @_filteredList = @options.items.where({idEvenement: @model.get('id')})
    return @_filteredList

  templateContext: ->
    { hash, ext } = @getSelectedAttr()
    {
      hash
      ext
      selectButton:@options.selectButton is true
      addFile:@options.addFile is true
      delFile: @options.delFile is true
      filesnumber: @filteredList().length
    }

}

export { FilesView }
