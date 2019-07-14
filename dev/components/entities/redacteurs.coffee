import { User } from "entities/user.coffee"

Item = User.extend {
  urlRoot: "api/redacteurs"

  parse: (data) ->
    if (data.id)
      data.id = Number(data.id)
    if (data.count_evenements)
      data.count_evenements = Number(data.count_evenements)
    else
      data.count_evenements = 0
    return data
}

Collection = Backbone.Collection.extend {
  url: "api/redacteurs"
  model: Item
  comparator: "nom"
}

export {
  Collection
  Item
}
