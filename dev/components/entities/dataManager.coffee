import Radio from 'backbone.radio'

API = {
  timeout:1500000
  stored_data:{}
  stored_time:{}

  getCustomEntities: (ask) ->
    t= Date.now()
    defer = $.Deferred()
    toFetch = _.filter ask, (item)-> (typeof API.stored_data[item] is "undefined") or (typeof API.stored_time[item] is "undefined") or (t-API.stored_time[item]>API.timeout)
    if toFetch.length is 0
      # Pas de fetch requis => on renvoie les résultats
      defer.resolve.apply(null,_.map(ask, (item)-> API.stored_data[item]))
    else
      request = $.ajax("api/customData/"+toFetch.join("&"),{
        method:'GET'
        dataType:'json'
      })

      request.done( (data)->
        for colName in ask
          switch colName
            when "joueurs" then colObj = require("entities/users.coffee")
            when "redacteurs" then colObj = require("entities/users.coffee")
            when "evenements" then colObj = require("entities/evenements.coffee")
            when "parties" then colObj = require("entities/parties.coffee")
            when "itemsEvenement" then colObj = require("entities/itemsEvenement.coffee")
            when "essaisJoueur" then colObj = require("entities/essaisJoueur.coffee")
            when "images" then colObj =  require("entities/images.coffee")
            else colObj = false
          if (colObj isnt false) and (data[colName])
            API.stored_data[colName] = new colObj.Collection(data[colName], { parse:true })
            API.stored_time[colName] = t
        defer.resolve.apply(null,_.map(ask, (item)-> API.stored_data[item] ))
      ).fail( (response)->
        defer.reject(response)
      )
    return promise = defer.promise()

  getEssais: (idPartie) ->
    defer = $.Deferred()

    url = "api/customData/essais/#{idPartie}"

    request = $.ajax(url,{
      method:'GET'
      dataType:'json'
    })

    request.done( (data)->
      OPartie = require("entities/parties.coffee").Item
      partie = new OPartie(data.partie)
      OEvenement = require("entities/evenements.coffee").Item
      evenement = new OEvenement(data.evenement)
      ColEssaisJoueur = require("entities/essaisJoueur.coffee").Collection
      essais = new ColEssaisJoueur(data.essais, {parse:true})
      defer.resolve(partie, evenement, essais, data.nomJoueur)
    ).fail( (response)->
      defer.reject(response)
    )
    return defer.promise()



  purge: ->
    console.log("purge des données")
    API.stored_data = {}

}

channel = Radio.channel('entities')
channel.reply('custom:entities', API.getCustomEntities )
channel.reply('custom:essais', API.getEssais )
channel.reply('data:purge', API.purge )
