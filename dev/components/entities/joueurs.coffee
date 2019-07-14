import { User } from "entities/user.coffee"

Item = User.extend {
  urlRoot: "api/joueurs"

  parse: (data) ->
    if (data.id)
      data.id = Number(data.id)
    if (data.count_parties)
      data.count_parties = Number(data.count_parties)
    else
      data.count_parties = 0
    return data
}

Collection = Backbone.Collection.extend {
  url: "api/joueurs"
  model: Item
  comparator: "nom"
}

export {
  Item
  Collection
}
