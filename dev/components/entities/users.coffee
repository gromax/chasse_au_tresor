Item = Backbone.Model.extend {
  urlRoot: "api/users"
  defaults: {
    nom: ""
    username: ""
    isredac: false
    count_evenements: 0
    count_parties: 0
  }

  parse: (data) ->
    if (data.id)
      data.id = Number(data.id)
    if (data.count_evenements)
      data.count_evenements = Number(data.count_evenements)
    if (data.count_parties)
      data.count_parties = Number(data.count_parties)
    return data

  toJSON: ->
    return _.pick(this.attributes, 'id', 'nom', 'username', 'pwd', 'isredac');

  validate: (attrs, options) ->
    errors = {}
    if (typeof attrs.nom isnt "undefined") and (attrs.nom.length<4)
      errors.nom = "Trop court, trop nul..."

    if (typeof attrs.username isnt "undefined")  and (attrs.username.length<4)
      errors.username = "Trop court, trop nul..."

    if (typeof attrs.pwd isnt "undefined") and (attrs.pwd.length<4)
      errors.pwd = "Trop court"

    if (typeof attrs.pwd2 isnt "undefined") and (attrs.pwd2 isnt attrs.pwd)
      errors.pwd2 = "Les mots de passe ne correspondent pas"

    if (typeof attrs.jenesuispasunrobot isnt "undefined") and (attrs.jenesuispasunrobot is false)
      errors.jenesuispasunrobot = "Robots interdits !"

    if not _.isEmpty(errors)
      return errors
}

Collection = Backbone.Collection.extend {
  url: "api/users"
  model: Item
  comparator: "nom"
}

export {
  Item
  Collection
}
