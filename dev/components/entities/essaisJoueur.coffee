Item = Backbone.Model.extend {
  urlRoot: "api/essaisJoueur"

  defaults: {
    idPartie: false
    idItem: false
    essai: ""
    tagCle: ""
    pts: 0
  },

  toJSON: ->
    out = _.pick(this.attributes, 'id', 'idPartie', 'essai', 'date', 'data')
    out['data'] = JSON.stringify(out['data'])
    return out

  parse: (data) ->
    if (data.id)
      data.id = Number(data.id)
    if data.pts
      data.pts = Number(data.pts)
    if (data.idPartie)
      data.idPartie = Number(data.idPartie)
    if (data.idItem)
      data.idItem = Number(data.idItem)
    if data.data then data.data = JSON.parse(data.data)
    else data.data = {}

    if (data.date)
      data.date_fr = data.date.replace(/([0-9]{4})-([0-9]{2})-([0-9]{2})\s*([0-9]{2}:[0-9]{2}:[0-9]{2})/,"$3/$2/$1 $4")
    else
      data.date_fr = ""
      data.date = ""

    return data

  validate: (attrs, options) ->
    errors = {}
    if not attrs.essai
      errors.essai = "Ne doit pas être vide"
    if not _.isEmpty(errors)
      return errors

}

Collection = Backbone.Collection.extend {
  url: "api/essaisJoueur"
  model: Item
  comparator: "date"
}

export {
  Item
  Collection
}
