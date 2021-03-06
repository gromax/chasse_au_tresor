import Radio from 'backbone.radio'

Item = Backbone.Model.extend {
  urlRoot: "api/evenements"

  defaults: {
    titre: ""
    idProprietaire: false
    description: ""
    actif: false
    sauveEchecs: false
    ptsEchecs: 0
    hash: ""
    modevent: false
    moditem: false
    isshare: false
  }

  parse: (data) ->
    if (data.id)
      data.id = Number(data.id)
    if (data.idProprietaire)
      data.idProprietaire = Number(data.idProprietaire)
    data.actif = (data.actif is "1") or (data.actif is 1) or (data.actif is true)
    data.visible = (data.visible is "1") or (data.visible is 1) or (data.visible is true)
    if (typeof data.isshare isnt "undefined")
      data.isshare = (data.isshare is "1") or (data.isshare is 1) or (data.isshare is true)
    if (typeof data.modevent isnt "undefined")
      data.modevent = (data.modevent is "1") or (data.modevent is 1) or (data.modevent is true)
    if (typeof data.moditem isnt "undefined")
      data.moditem = (data.moditem is "1") or (data.moditem is 1) or (data.moditem is true)
    if (data.count_parties)
      data.count_parties = Number(data.count_parties)
    else
      data.count_parties = 0
    if (data.count_items)
      data.count_items = Number(data.count_items)
    else
      data.count_items = 0
    if typeof data.idPartie isnt 'undefined'
      if data.idPartie isnt null
        data.idPartie = Number data.idPartie
      else
        data.idPartie = false
      data.fini = (data.fini is "1") or (data.fini is 1) or (data.fini is true)
    if typeof data.ptsEchecs isnt 'undefined'
      data.ptsEchecs = Number data.ptsEchecs
    data.sauveEchecs = (data.sauveEchecs is "1") or (data.sauveEchecs is 1) or (data.sauveEchecs is true)
    return data

  toJSON: ->
    return _.pick(this.attributes, 'id', 'idProprietaire', 'titre', 'description', 'actif', 'visible', 'sauveEchecs', 'ptsEchecs');

  validate: (attrs, options) ->
    errors = {}
    if not attrs.titre
      errors.titre = "Ne doit pas être vide"
    if not _.isEmpty(errors)
      return errors
}

Collection = Backbone.Collection.extend {
  url: "api/evenements"
  model: Item
  comparator: "titre"
}

API = {
  getWithHash: (hash)->
    defer = $.Deferred()
    request = $.ajax("api/event/hash/#{hash}",{
      method:'GET'
      dataType:'json'
      data: {}
    })

    request.done( (data)->
      evenement = new Item(data, {parse:true})
      defer.resolve evenement
    ).fail( (response)->
      defer.reject(response)
    )
    return defer.promise()
}

channel = Radio.channel('entities')
channel.reply('evenement:hash', API.getWithHash )


export {
  Item
  Collection
}
