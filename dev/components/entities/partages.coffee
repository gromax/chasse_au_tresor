import Radio from 'backbone.radio'

Item = Backbone.Model.extend {
  urlRoot: "api/partages"

  defaults: {
    nom: ""
    idRedacteur: false
    idEvenement: false
  }

  parse: (data) ->
    if (data.id)
      data.id = Number(data.id)
    if (data.idRedacteur)
      data.idRedacteur = Number(data.idRedacteur)
    if (data.idEvenement)
      data.idEvenement = Number(data.idEvenement)
    return data

  toJSON: ->
    return _.pick(this.attributes, 'id', 'idRedacteur', 'idEvenement');
}

Collection = Backbone.Collection.extend {
  url: "api/partages"
  model: Item
  comparator: "nom"
}

API = {
  getPartagesEventList: (idEvenement)->
    defer = $.Deferred()
    request = $.ajax("api/evenement/#{idEvenement}/partages",{
      method:'GET'
      dataType:'json'
      data: {}
    })

    request.done( (data)->
      partages = new Collection(data.partages, {parse:true})
      OEvenement = require("entities/evenements.coffee").Item
      evenement = new OEvenement(data.evenement, {parse:true})
      defer.resolve evenement, partages
    ).fail( (response)->
      defer.reject(response)
    )
    return defer.promise()
  getUserWithNoPartage: (idEvenement)->
    defer = $.Deferred()
    request = $.ajax("api/evenement/#{idEvenement}/userswithnopartages",{
      method:'GET'
      dataType:'json'
      data: {}
    })

    request.done( (data)->
      UserItem = Backbone.Model.extend {
        parse: (data) ->
          if (data.id)
            data.id = Number(data.id)
          return data
      }
      UsersCollection = Backbone.Collection.extend {
        model: UserItem
        comparator: "nom"
      }
      users = new UsersCollection(data, {parse:true})
      defer.resolve users
    ).fail( (response)->
      defer.reject(response)
    )
    return defer.promise()
}

channel = Radio.channel('entities')
channel.reply('evenement:partages', API.getPartagesEventList )
channel.reply('evenement:users:nopartages', API.getUserWithNoPartage )

export {
  Item
  Collection
}
