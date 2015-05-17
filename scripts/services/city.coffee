App.service 'City', ['Storage', class
  constructor: (Storage) ->
    @cities = Storage.get('cities') or []
    @save = -> Storage.set 'cities', @cities.map (city) ->
      delete city['$$hashKey']
      city

  get: (name) ->
    result = null
    @cities.forEach (city) ->
      result = city if name is city.name
    result

  getAll: -> @cities

  add: (data) ->
    @cities.push data
    @save()

  has: (name) -> @get(name)?

  remove: (name) ->
    @cities = @cities.filter (city) ->
      city.name isnt name
    @save()

  touch: (name) -> @update name, 'lastUpdate', +(new Date)

  needForUpdate: (name) ->
    city = @get name
    not city.lastUpdate or +(new Date) - city.lastUpdate > 10 * 60 * 1000

  update: (name, key, value) ->
    @cities = @cities.map (city) ->
      if city.name is name
        city[key] = value
      city
]